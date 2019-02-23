defmodule Exmud.Engine.Command do
  @moduledoc """
  A Command is a piece of game logic intended to be invoked on behalf on an Object.

  A Command can be invoked by a player who has puppeted an Object, a Script, or by the Engine via some external trigger.

  A Command has multiple attributes:
    Key: Required
      The action to be taken. This can be more than one word, so 'open third window' or 'tap second case' are just as
      valid as 'look' or 'move'.

    Aliases: Optional
      Aliases by which the command can be known. When a command string is being processed, both the key and the aliases
      are used to determine a match. That also means that both keys and aliases are checked during a merge between
      Command Sets.

      One example would be the alias 'flee' for the command 'retreat'. Another primary use is the explicit whitelisting
      of short cuts for Commands. The 'retreat' command might allow for 'retrea', 'retre', and 'retr' to match but
      nothing shorter due to potential conflicts with a wider range of Commands.

      Then again, given that a 'retreat' command would likely belong to a higher priority combat oriented Command Set,
      any conflicts would be decided in the favor of the 'retreat' command so even shorter aliases become a possibility.

    Execute: Required
      Every Command will require its own implementation of the 'execute/1' callback. This is where the actual logic
      execution for a Command takes place.

      The callback is wrapped in a transaction, ensuring that all data can be accessed as if the Command execution
      function was the sole process. This also means the callback may need to be retried and as such must be side effect
      free, except for manipulating the database of course.

      Any Events generated as part of a Command execution must be added to the returned context for processing after
      the transaction has been committed.

    Locks: Optional
      Locks help determine who/what has access to the Command itself. It's not enough for a Command to end up in the
      final merged Command Set, the caller must also have permissions for the Command itself. This defaults to allowing
      all callers.

    Help Docs: Optional
      Docs can be automatically generated from the module documentation to be displayed within the game. Not only can
      the doc generation be turned off, but an optional category can be set. Defaults to generating documentation with
      the category set to 'General'.

    Argument Regex: Optional
      An optional regex string to match against the argument string. The default regex '~r/$/' allows for mistyped
      commands like 'runeast' to match. Overriding the value to something like '~r/^\s.+' would enforce a space to come
      between the command and any of its arguments. If not specified in the Command module itself, the regex is taken
      from the config.

      If this regex does not match the 'parse_args/1' callback will not be called.
  """

  alias Exmud.Engine.Command.ExecutionContext
  alias Exmud.Engine.Event
  import Exmud.Engine.Utils
  require Logger

  #
  # Struct definition
  #

  @enforce_keys [:key, :execute, :object_id]
  defstruct key: nil,
            aliases: [],
            doc_generation: false,
            doc_category: "General",
            doc: "",
            execute: nil,
            parse_args: nil,
            locks: [Exmud.Engine.Locks.Any],
            argument_regex: engine_cfg(:command_argument_regex),
            # Object that the command is attached to
            object_id: nil,
            # The config from a Command Set is passed down to all of its Commands
            config: %{}

  @type t :: %Exmud.Engine.Command{
          key: String.t(),
          aliases: [String.t()],
          doc_generation: boolean,
          doc_category: String.t(),
          doc: String.t(),
          execute: function,
          parse_args: function,
          locks: [module | {module, config}],
          argument_regex: term,
          object_id: integer,
          config: Map.t()
        }

  #
  # Behavior definition and default callback setup
  #

  @doc false
  defmacro __using__(_) do
    quote location: :keep do
      @behaviour Exmud.Engine.Command
      import Exmud.Engine.Constants

      @doc false
      def aliases(_config), do: []

      @doc false
      def doc_generation(_config), do: true

      @doc false
      def doc_category(_config), do: command_doc_category_general()

      @doc false
      def parse_args(context), do: {:ok, %{context | args: String.trim(context.raw_args)}}

      @doc false
      def locks(_config), do: [Exmud.Engine.Lock.Any]

      @doc false
      def argument_regex(_config), do: engine_cfg(:command_argument_regex)

      defoverridable aliases: 1,
                     doc_generation: 1,
                     doc_category: 1,
                     parse_args: 1,
                     locks: 1,
                     argument_regex: 1
    end
  end

  @doc """
  The aliases by which the command can also be matched.
  """
  @callback aliases(config) :: [String.t()]

  @doc """
  Called when the Engine determines the Command should be executed. This means all the matching, parsing, and
  permissions checks have passed.

  An execution context is passed to the callback function, populated with several helpful bits of information to aid in
  the execution of the command. See 'Exmud.Engine.Command.ExecutionContext'.
  """
  @callback parse_args(context) :: {:ok, context} | {:error, context}

  @doc """
  Called when the Engine determines the Command should be executed. This means all the matching, parsing, and
  permissions checks have passed. This is called after 'parse_args/1', assuming there was no error.

  An execution context is passed to the callback function, populated with several helpful bits of information to aid in
  the execution of the command. See 'Exmud.Engine.Command.ExecutionContext'.
  """
  @callback execute(context) :: {:ok, context} | {:error, error, context}

  @doc """
  The prmary string used to match the command with player input.
  """
  @callback key(config) :: String.t()

  @doc """
  The locks that must pass for the Command to be accessed.
  """
  @callback locks(config) :: [module]

  @doc """
  Whether or not to generate docs from the callback module. Defaults to true.
  """
  @callback doc_generation(config) :: boolean

  @doc """
  The category to put the docs under if they are generated. Defaults to 'General'.
  """
  @callback doc_category(config) :: String.t()

  @doc """
  The compiled regex expression that the argument string must pass before the parse callback is called.
  """
  @callback argument_regex(config) :: term

  @typedoc "Arguments passed through to a callback module."
  @type args :: term

  @typedoc "The argument string is everything after the key that has been matched."
  @type arg_string :: String.t()

  @typedoc "The Command struct representing the state of the Command being processed."
  @type command :: Exmud.Engine.Command.t()

  @typedoc "An error message."
  @type error :: term

  @typedoc "An map containing arbitrary keys and values understood and used by the Command Set and/or its Commands."
  @type config :: Map.t()

  @typedoc "An execution context providing the required information to execute a command."
  @type context :: %Exmud.Engine.Command.ExecutionContext{}

  #
  # API
  #

  @command_pipeline engine_cfg(:command_pipeline)

  @doc false
  @spec execute(integer(), String.t(), [module()]) ::
          {:ok, context} | {:error, error, module(), context}
  def execute(caller, raw_input, pipeline \\ @command_pipeline) do
    context = %ExecutionContext{caller: caller, raw_input: raw_input}

    result =
      retryable_transaction(fn ->
        execute_steps(pipeline, context)
      end)

    case result do
      %ExecutionContext{} = context ->
        for event <- context.events do
          :ok = Event.dispatch(event)
        end

        {:ok, context}

      {:error, error, pipeline_step, context} = err ->
        Logger.error(
          "Command execution failed. Error: #{error}, Step: #{pipeline_step}, Caller: #{
            context.caller
          }, Raw Input: #{context.raw_input}"
        )

        err
    end
  end

  @spec execute_steps([], context) :: context
  defp execute_steps([], context) do
    context
  end

  defp execute_steps([pipeline_step | pipeline_steps], context) do
    case pipeline_step.execute(context) do
      {:ok, context} ->
        execute_steps(pipeline_steps, context)

      {:error, error, context} ->
        {:error, error, pipeline_step, context}
    end
  end
end

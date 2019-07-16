defmodule Exmud.Engine.Command do
  @moduledoc """
  A Command is a piece of game logic intended to be invoked on behalf on an Object.

  The Command struct is intended to be used as part of a Command Set struct when building an active Command Set. It
  contains the callback module which implements this behaviour, the app provided config, and the id of the Object to
  which the Command is attached.

  The callbacks define the api required for the module to be compatable with the intended usage of said module. Putting
  'use Exmud.Engine.Command' at the top of a Command module will not only have the Command behaviour applied, but will
  be provided with a number of default implementations of various callbacks. See the callback docs.
  """

  alias Exmud.Engine.Command.ExecutionContext
  alias Exmud.Engine.Event
  import Exmud.Engine.Utils
  require Logger

  #
  # Struct definition
  #

  @enforce_keys [:callback_module, :config, :object_id]
  defstruct callback_module: nil,
            config: %{},
            object_id: nil

  @type t :: %Exmud.Engine.Command{
          callback_module: module,
          config: Map.t(),
          object_id: integer
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
      def parse_args(context), do: {:ok, %{context | args: context.raw_args}}

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

  When a command string is being processed, both the key and the aliases are used to determine a match. That also means
  that both keys and aliases are checked during a merge between Command Sets.

  One example would be the alias 'flee' for the command 'retreat'. Another primary use is the explicit whitelisting of
  short cuts for Commands. The 'retreat' command might allow for 'retrea', 'retre', and 'retr' to match but nothing
  shorter due to potential conflicts with a wider range of Commands.

  Then again, given that a 'retreat' command would likely belong to a higher priority combat oriented Command Set, any
  conflicts would be decided in the favor of the 'retreat' command so even shorter aliases become a possibility.

  These and the key are checked first during the execution of input.

  This is optional. Will return an empty list by default.
  """
  @callback aliases(config) :: [String.t()]

  @doc """
  This is called both to determine if the Command is a match for the input, and to prepare that input for execution.

  By default it is executed after the locks have been checked. If an error is returned, the Command is not considered a
  match for the input and it is dropped from consideration. If multiple commands, from the final active Command Set,
  return '{:ok, context}' then a multiple match error has occurred.

  An execution context is passed to the callback function, populated with several helpful bits of information to aid in
  the execution of the command. See 'Exmud.Engine.Command.ExecutionContext'.

  This is optional. A default which simply passes along the input stream is provided.
  """
  @callback parse_args(context) :: {:ok, context} | {:error, context}

  @doc """
  Called when the Engine determines the Command should be executed. This means all the matching, parsing, and
  permissions checks have passed. This is called after 'parse_args/1', assuming there was no error.

  This is where the actual logic execution for a Command takes place.. An execution context is passed to the callback
  function, populated with several helpful bits of information to aid in the execution of the command. See
  'Exmud.Engine.Command.ExecutionContext'.

  The callback is wrapped in a transaction, ensuring that all data can be accessed as if the Command execution function
  was the sole process. This also means the callback may need to be retried and as such must be side effect free, except
  for manipulating the database of course.

  Any Events generated as part of a Command execution must be added to the returned context for processing after the
  transaction has been committed.

  This is required, and no default is provided.
  """
  @callback execute(context) :: {:ok, context} | {:error, error, context}

  @doc """
  The primary string used to match the command with player input.

  This, along with aliases, is where the commands are defined. A command might be simple, like '"climb up"',
  "move west", or "throw spear at goblin". It might also be more complex, such as `"press tiny button on the left of the
  crevice behind the fifth book from the left on the top shelf of the third bookcase from the left"

  This is required, and no default is provided.
  """
  @callback key(config) :: String.t()

  @doc """
  Locks help determine who/what has access to the Command itself.

  It's not enough for a Command to end up in the final merged Command Set, the caller must also have permissions for the
  Command itself. By default this is called after the key and aliases are checked, and before the args are parsed.

  This is optional. A default which allows all callers is provided.
  """
  @callback locks(config) :: [module]

  @doc """
  Whether or not to generate docs from the callback module.

  Docs can be automatically generated from the module documentation to be displayed within the game. Not only can the
  doc generation be turned off, but an optional category can be set. Defaults to generating documentation with
      the category set to 'General'.

  This is optional. A default which replies true is provided.
  """
  @callback doc_generation(config) :: boolean

  @doc """
  What category to use when generating docs.

  This is optional. Defaults to 'General'.
  """
  @callback doc_category(config) :: String.t()

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

defmodule Exmud.Engine.Command do
  @moduledoc """
  A Command is a piece of game logic intended to be invoked on behalf on an Object, whether this be by a player who has puppeted an Object, a Script, or by the Engine via some external trigger.

  A Command has multiple attributes:
    Key - The action to be taken. This can be more than one word, so 'open third window' or 'tap second case' are just
          as valid as 'look' or 'move'.

    Aliases - Aliases by which the command can be known. When a command string is being processed, both the key
              and the aliases are used to determine a match. That also means that both verbs and aliases are checked
              during a merge between Command Sets.

              One example would be the alias 'flee' for the command 'retreat'. Another primary use is the explicit
              whitelisting of short cuts for Commands. The 'retreat' command might allow for 'retrea', 'retre', and
              'retr' to match but nothing shorter due to potential conflicts with a wider range of Commands.

              Then again, given that a 'retreat' command would likely belong to a higher priority combat oriented
              Command Set, any conflicts would be decided in the favor of the 'retreat' command so even shorter aliases
              become a possibility.

    Executor - A do-nothing default implementation has been provided simply to make a Command work out-of-the-box, but
               every Command will require its own implementation of the 'execute/1' callback. This is where the actual
               logic execution for a Command takes place.

               The callback is wrapped in a transaction, ensuring that all data can be accessed as if the Command
               execution function was the sole process. This also means the callback may need to be retried, and as
               such must be side effect free, except for manipulating the database of course.

    Locks - Locks help determine who/what has access to the Command itself. It's not enough for a Command to end up in
            the final merged Command Set, the caller must also have permissions for the Command itself. This defaults
            to allowing all callers.

    Help Docs - Docs can be automatically generated from the module documentation to be displayed within the game. Not
                only can the doc generation be turned off, but an optional category can be set. Defaults to 'General'.

    Argument Regex - An optional regex string to match against the argument string. The default regex '~r/$/' allows for
                     mistyped commands like 'runeast' to match. Overriding the value to something like '~r/^\s.+' would
                     enforce a space to come between the command and any of its arguments.

                     If this regex does not match the parse callback will not be called.


  """

  alias Ecto.Multi
  alias Exmud.Engine.Command.ExecutionContext
  alias Exmud.Engine.Repo
  import Exmud.Common.Utils
  import Exmud.Engine.Utils
  require Logger
  use GenServer, restart: :transient


  #
  # Behavior definition and default callback setup
  #


  @doc false
  defmacro __using__(_) do
    quote location: :keep do
      @behaviour Exmud.Engine.Command

      @doc false
      def aliases, do: []

      @doc false
      def doc_generation, do: true

      @doc false
      def doc_category, do: "General"

      @doc false
      def execute(_context), do: :ok

      @doc false
      def locks, do: [Exmud.Engine.Lock.Any]

      @doc false
      def argument_regex(_args_string), do: engine_cfg(:command_argument_regex)

      defoverridable aliases: 0,
                     doc_generation: 0,
                     doc_category: 0,
                     execute: 1,
                     locks: 0,
                     argument_regex: 1
    end
  end

  @doc """
  The aliases by which the command can also be matched.
  """
  @callback aliases :: [String.t()]

  @doc """
  Called when the Engine determines the Command should be executed. This means all the matching, parsing, and permissions checks have passed.

  An execution context is passed to the callback function, populated with several helpful bits of information to aid in the execution of the command. See 'Exmud.Engine.CommandContext'.
  """
  @callback execute(context) :: :ok | {:error, error}

  @doc """
  This callback allows for arbitrarily overriding the middleware pipeline executed on a Command.

  It receives the name of a Middleware module and an `%Exmud.Engine.Command.ExecutionContext{}` struct and should return one or more Middleware modules. If returning a single module name it does not have to be wrapped in a list.
  """
  @callback middware(middleware, Exmud.Engine.Command.ExecutionContext.t()) :: middleware | [middleware]

  @doc """
  The action to be taken.
  """
  @callback key :: String.t()

  @doc """
  Whether or not to generate docs from the callback module. Defaults to true.
  """
  @callback doc_generation :: boolean

  @doc """
  The category to put the docs under if they are generated. Defaults to 'General'.
  """
  @callback doc_category :: String.t()

  @doc """
  The compiled regex expression that the argument string must pass before the parse callback is called.
  """
  @callback argument_regex :: term

  @typedoc "Arguments passed through to a callback module."
  @type args :: term

  @typedoc "The Command struct representing the state of the Command being processed."
  @type command :: term

  @typedoc "An error message."
  @type error :: term

  @typedoc "The name of a Middleware module."
  @type middleware :: atom

  #
  # API
  #


  @default_command_pipeline engine_cfg(:command_pipeline)

  @doc false
  def execute(caller, raw_input, pipeline \\ @default_command_pipeline) do
    context = %ExecutionContext{caller: caller, raw_input: raw_input}

    execute_steps(pipeline, context)
  end

  defp execute_steps([], execution_context), do: execution_context

  defp execute_steps([pipeline_step | pipeline_steps], execution_context) do
    case pipeline_step.execute(execution_context) do
      {:ok, execution_context} ->
        execute_steps(pipeline_steps, execution_context)
      error ->
        error
    end
  end
end

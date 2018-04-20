defmodule Exmud.Engine.Command do
  @moduledoc """
  A Command is a piece of game logic intended to be invoked on behalf on an Object, whether this be by a Player who has
  puppeted an Object, a script, or by the Engine via some external trigger.

  A Command has multiple attributes:
    Key - The action to be taken. This can be more than one word, so 'open third window' or 'tap second case' are just
          as valid as 'look' or 'move'.

    Aliases - Aliases by which the command can be known. When a command string is being processed, both the exact verb
              and the aliases are used to determine a match. That also means that both verbs and aliases are checked
              during a merge between Command Sets.

              One example would be the alias 'flee' for the command 'retreat'. Another primary use is the explicit
              whitelisting of short cuts for Commands. The 'retreat' command might allow for 'retrea', 'retre', and
              'retr' to match but nothing shorter due to potential conflicts with a wider range of Commands.

              Then again, given that a 'retreat' command would likely belong to a higher priority combat oriented
              Command Set, any conflicts would be decided in the favor of the 'retreat' command so even shorter aliases
              become a possibility.

    Parser - While a built in parser has been provided, overriding the 'parse/1' hook allows for the customized
             processing of the command string after the verb. So for the command 'look under the shelf in the bathroom'
             the string provided to the parser would be 'under the shelf in the bathroom'.

             The returned value from this function is passed to the execution callback.

    Executor - A do-nothing default implementation has been provided simply to make a Command work out-of-the-box, but
               every Command will require its own implementation of the 'execute/1' callback. This is where the actual
               logic execution for a Command takes place.

               The callback is wrapped in a transaction, ensuring that all data can be accessed as if the Command
               execution function was the sole process.

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
  alias Exmud.Engine.Repo
  import Ecto.Query
  import Exmud.Common.Utils
  import Exmud.Engine.Utils
  require Logger

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
      def parse(args_string), do: Exmud.Engine.CommandParser.parse(args_string)

      @doc false
      def args_regex(_args_string), do: ~r/$/

      defoverridable aliases: 0,
                     doc_generation: 0,
                     doc_category: 0,
                     execute: 1,
                     locks: 0,
                     parse: 1,
                     args_regex: 1
    end
  end

  @doc """
  The aliases by which the command can also be matched.
  """
  @callback aliases :: [String.t()]

  @doc """
  Called when the Engine determines the Command should be executed. This means all the matching, parsing, and
  permissions checks have passed.

  An execution context is passed to the callback function, populated with several helpful bits of information to aid in
  the execution of the command. See 'Exmud.Engine.CommandContext'.
  """
  @callback execute(context) :: :ok | {:error, error}

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
  Parse the argument string into a format expected by the execute callback.
  """
  @callback parse(args_string :: String.t()) :: term

  @doc """
  The compiled regex expression that the argument string must pass before the parse callback is called.
  """
  @callback args_regex :: term

  @typedoc "Arguments passed through to a callback module."
  @type args :: term

  @typedoc "The Command struct representing the state of the Command being processed."
  @type command :: term

  @typedoc "An error message."
  @type error :: term


  #
  # API
  #


  @doc false
  def execute(object_id, command_string) do
    gen_server_args = [
      object_id,
      command_string
    ]

    with {:ok, _} <-
           DynamicSupervisor.start_child(
             Exmud.Engine.CommandSupervisor,
             {CommandExecutor, gen_server_args}
           ) do
      :ok
    end
  end

  #
  # Manipulation of Callbacks in the Engine.
  #

  @cache :callback_cache

  @doc """
  List all Callbacks currently registered with the Engine.
  """
  def list_registered() do
    Logger.info("Listing all registered Callbacks")
    Cache.list(@cache)
  end

  @doc """
  Return the Callback module that has been registered with a given name.
  """
  def lookup(name) do
    case Cache.get(@cache, name) do
      {:error, _} ->
        Logger.error("Lookup failed for Callback registered with name `#{name}`")
        {:error, :no_such_callback}

      result ->
        Logger.info("Lookup succeeded for Callback registered with name `#{name}`")
        result
    end
  end

  @doc """
  Callbacks are registered with the Engine via a unique name.

  Takes in a Callback module, calling the 'name/0' method on said module, and registers it with the Engine. Registering
  a second module with the same name as a previous one will overwrite the first entry.
  """
  def register(callback_module) do
    Logger.info(
      "Registering Callback with name `#{callback_module.name()}` and module `#{
        inspect(callback_module)
      }`"
    )

    Cache.set(@cache, callback_module.name(), callback_module)
  end

  @doc """
  Check to see if there is a Callback module registered with a given name.
  """
  def registered?(callback_module) do
    Logger.info("Checking registration of Callback with name `#{callback_module.name()}`")
    Cache.exists?(@cache, callback_module.name())
  end

  @doc """
  Unregister a call default Callback from the system.
  """
  def unregister(callback_module) do
    Logger.info("Unregistering Callback with name `#{callback_module.name()}`")
    Cache.delete(@cache, callback_module.name())
  end

  #
  # Internal Functions
  #

  defp callback_query(object_id, key) do
    from(callback in Callback, where: callback.object_id == ^object_id and callback.key == ^key)
  end
end

defmodule Exmud.Engine.Callback do
  @moduledoc """
  An `Exmud.Object` can have an arbitrary number of Callbacks associated with it.

  Callbacks are designed to work alongside Commands when dynamic behavior on an Object is required. Much like Commands
  are added/removed on Objects via Command Sets, Callbacks are added/removed from Objects via Callback Sets.

  Designed to be called from within context of a Command, Callbacks can be used for a variety of different tasks such
  as modifying a string before it gets sent, or sending a message after a certain event has taken place.

  When a custom Callback for an Object has not been registered, a default implementation may be used instead. These can
  be specified by passing a name to be used to lookup a default module, which is how the engine behaves for its
  internal hooks, or by passing a function to be called directly. Default implementations have been provided for all
  engine hooks. This logic can be applied in application code as well as when writing Scripts and Commands.

  Callbacks have two different methods of being identified that are used in different ways. The key and the name. The
  name is a unique string that identifies a Callback module within the Engine and is useful for not only exploring the
  state of the Engine, but for providing default fallbacks if a matching Callback key cannot be found on an Object.

  Callback keys are unique per-object, with the addition of a second overwriting the first, and are used for behavior
  hooks at runtime. In the example of an Object being puppeted, the Engine will first look for a Callback on an Object
  with the key "pre_puppet", and if it cannot find one will look for a named default implementation. The provided
  default "pre_puppet" Callback checks the Locks on an Object to make sure the one doing the puppeting has permission.

  Note that all methods in this module, and all Callback modules/functions, are executed in the context of the calling
  process.
  """

  alias Exmud.Engine.Cache
  alias Exmud.Engine.ObjectUtil
  alias Exmud.Engine.Repo
  alias Exmud.Engine.Schema.Callback
  import Ecto.Query
  import Exmud.Engine.Utils
  require Logger

  #
  # Behavior definition and default callback setup
  #

  @doc false
  defmacro __using__(_) do
    quote location: :keep do
      @behaviour Exmud.Engine.Callback

      @doc false
      def execute(command, _args), do: command

      defoverridable name: 0,
                     run: 2
    end
  end

  @doc """
  Called when the Engine determines the Callback should be executed.

  The Callback is called with the Command struct, containing all the necessary information to execute on a Command, and
  the optional initialized args. It must return a new command object.
  """
  @callback execute(command, args) :: command

  @typedoc "Arguments passed through to a callback module."
  @type args :: term

  @typedoc "The Command struct representing the state of the Command being processed."
  @type command :: term

end

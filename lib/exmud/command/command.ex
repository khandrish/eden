defmodule Exmud.Command do
  @moduledoc """
  A command is a distinct action that can be executed within the system.

  ## Callbacks
  All command callbacks, and others related to the processing of a command string from start to finish, are executed in
  the same `Repo.transaction/1` call, ensuring that the relevant game world is consistent for the processing
  of a command string.

  In a worst case scenario, there would be a process per player plus a process per running system/script attemping
  to access the database to modify the state of the game world. To compensate for this parallel behavior, all
  logic related to the processing of a command string from start to finish must be executed inside a transaction so
  that it can be written without having to consider possible race conditions. This is handled transparently to the
  callback module, and putting transactions in the callback module should pose no problems.

  ## Command Struct
  When the engine determines which command is to be executed it first calls the `parse/1` callback so a custom term can
  be constructed for the `execute/1` callback. The term returned from the `parse/1` callback is then inserted into an
  `%Exmud.Command{}` struct along with a few additional values which should provide the `execute/1` callback with enough
  context to properly execute. This command struct is then passed into the `execute/1` callback.

  ## Example:
  A command struct being passed into the `execute/1` callback might look something like this:
  ```
    %Exmud.Command{
      # This struct would be returned from the parse/1 callback
      args: %Args{
        message: "Ohh, Micky, you're so fine!",
        targets: ["Micky"],
        tone: "cheery"
      },
      object: 4,
      match_string: "shout",
      subject: 2
    }
  ```
  """

  @doc """
  Parse the arguments string.

  Assuming the default Exmud behavior has not been overwritten, the args_string will be everything after the characters
  which were mapped to a command minus any leading spaces. So if the full string being processed is 'move north' or
  'go north' this function would receive 'north' as the string to parse.

  A more advanced use of the parse callback would be to allow multiple types and number of arguments. For example, an
  advanced command might look like this: `shout @Micky /cheery Ohh, Micky, you're so fine!`

  In such a case, the term which is returned might look something like this:
  ```
    %Args{
      message: "Ohh, Micky, you're so fine!",
      targets: ["Micky"],
      tone: "cheery"
    }
  ```

  ## Failure
  Returning an error may (see `init/1`) trigger the help documentation for the command to be shown to the player. In
  either case, any returned error message will be displayed to the player. Returning `:error` by itself will not
  display any custom message to the player, other than any help docs which may be shown.
  """
  @callback parse(args_string) :: {:ok, term} | {:error, error_message} | :error

  @doc """
  Do all the things.

  Return value is ignored.
  """
  @callback execute(command) :: term

  @doc """
  Initialize a command template for the engine to use when processing command strings.

  Command templates are initialized on demand via the inclusion of a command set in the processing of a command string.
  Note that this callback will be called every time a command is included in the processing of a command string. In the
  case of an object, such as a fountain, on a main thoroughfare every single command from every single player passing
  through would cause this function to be called so that the command key/aliases could be matched against the incoming
  command string.
  """
  @callback init(object) :: command_template

  @typedoc "The id of the object that the command is being built for."
  @type object :: term | nil

  @typedoc "A command object."
  @type command :: %Exmud.Command{}

  @typedoc "A string to return to the player."
  @type error_message :: String.t

  @typedoc "The reason for the failure."
  @type reason :: term

  @typedoc "The raw arguments string. This is everything after the command itself."
  @type args_string :: String.t

  @typedoc "The regex string used to parse the arguments."
  @type arg_regex :: term

  @typedoc "The template defining how the callback module will be indexed in the engine."
  @type command_template :: %Exmud.CommandTemplate{}

  # This struct represents all the information about a command that is used in the process of execution.
  defstruct(
    args: nil, # The processed arguments, which might look like %{direction: "north"} or even %Move{direction: "north"}
    object: nil, # The id of the object on which the command is being executed.
    match_string: nil, # The string which was matched. For "go north" the value would be "go".
    subject: nil, # The id of the calling object. e.g., An object puppeted by a player, or a script on an object.
  )

  @doc false
  def new, do: %Exmud.Command{}

  @doc false
  def get_args(command), do: command.args

  @doc false
  def set_args(command, args), do: %{command | args: args}

  @doc false
  def get_object(command), do: command.object

  @doc false
  def set_object(command, object), do: %{command | object: object}

  @doc false
  def get_match_string(command), do: command.match_string

  @doc false
  def set_match_string(command, match_string), do: %{command | match_string: match_string}

  @doc false
  def get_subject(command), do: command.subject

  @doc false
  def set_subject(command, subject), do: %{command | subject: subject}
end

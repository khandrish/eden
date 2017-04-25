defmodule Exmud.Command do
  @moduledoc """
  A command is a distinct action that can be executed within the system.

  The behavior defined below is the contract for users of `Exmud` to follow
  when constructing their command logic.
  """

  @doc """
  Parse the arguments string.

  Assuming the default Exmud behavior has not been overwritten, the args_string
  will be everything after the characters which were mapped to a command minus
  any leading spaces. So if the full string being processed is 'move north' or
  'go north' this function would receive 'north' as the string to parse.

  A more advanced use of the parse callback would be to allow multiple types and
  number of arguments. For example, an advanced command might look like
  this: `shout @Micky /cheery Ohh, Micky, you're so fine!`

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
  either case, any returned error message will be displayed to the player. An empty string or `nil` will display no
  message to the player, even if auto help is turned off.
  """
  @callback parse(args_string) :: {:ok, term} | {:error, error_message}

  @doc """
  Do all the things.

  Return value is ignored.
  """
  @callback execute(command) :: term

  @doc """
  Initialize a command template for the engine to use in indexing the callback module.

  Commands are added to the engine via their inclusion in command sets. When a command set is registered with the
  engine all commands contained in that command set are registered as well, assuming they haven't already been. This
  callback is only called that first time the command is being registered with the engine.
  """
  @callback init(object) :: {:ok, command_template} | {:error, reason}

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

  def new, do: %Exmud.Command{}

  def get_args(command), do: command.args

  def set_args(command, args), do: %{command | args: args}

  def get_object(command), do: command.object

  def set_object(command, object), do: %{command | object: object}

  def get_match_string(command), do: command.match_string

  def set_match_string(command, match_string), do: %{command | match_string: match_string}

  def get_subject(command), do: command.object

  def set_subject(command, subject), do: %{command | subject: subject}
end

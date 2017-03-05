defmodule Exmud.Command do
  @moduledoc """
  A command is a distinct piece of logic that can be executed by a player.
  """

  @doc """
  Use the provided regex string to parse the arguments.

  The return value should be a term which will be passed through to the execute
  callback, via insertion into the command object, and used there.
  """
  @callback parse(args_string, arg_regex) :: term

  @doc """
  Do all the things.

  Return value is ignored.
  """
  @callback execute(command) :: term

  @doc """
  Initialize a new command.

  All custom logic to build a command takes place here. This consists of little
  more than adding the appropriate values and returning the populated object.
  The magic all happens in the parse and execute callback methods of a
  callback module.
  """
  @callback init(object) :: {:ok, command} | {:error, reason}

  @typedoc "The id of the object that the command is being built for."
  @type object :: term | nil

  @typedoc "A command object."
  @type command :: term

  @typedoc "The reason for the failure."
  @type reason :: term

  @typedoc "The raw arguments string. This is everything after the command itself."
  @type args_string :: String.t

  @typedoc "The regex string used to parse the arguments."
  @type arg_regex :: term

  # This struct is for use when a command is being executed
  defstruct(
    aliases: MapSet.new(),
    arg_parse_result: nil,
    arg_regex: nil,
    auto_help: true,
    callback_module: nil,
    caller: nil,
    help_category: "General",
    key: nil,
    matched_command_args: nil,
    matched_command_key: nil,
    merged_command_set: nil,
    oid: nil,
    player: nil,
    raw_input: nil,
    session_id: nil
  )

  def new, do: %Exmud.Command{}

  # Manipulate aliases on a command object

  def add_alias(command, a) do
    %{command | commands: MapSet.put(command.aliases, a)}
  end

  def has_alias?(command, a), do: MapSet.member?(command.aliases, a)

  def remove_alias(command, a) do
    %{command | commands: MapSet.delete(command.aliases, a)}
  end

  # Set various values on a command object

  def set_arg_parse_result(command, result), do: %{command | arg_parse_result: result}

  def set_arg_regex(command, regex), do: %{command | arg_regex: regex}

  def set_auto_help(command, maybe), do: %{command | auto_help: maybe}

  def set_callback_module(command, module), do: %{command | callback_module: module}

  def set_help_category(command, category), do: %{command | help_category: category}

  def set_key(command, key), do: %{command | key: key}

  def set_caller(command, caller), do: %{command | caller: caller}

  def set_session_id(command, session_id), do: %{command | session_id: session_id}

  def set_player(command, player), do: %{command | player: player}

  def set_matched_command_key(command, command_key), do: %{command | matched_command_key: command_key}

  def set_matched_command_args(command, command_args), do: %{command | matched_command_args: command_args}

  def set_oid(command, oid), do: %{command | oid: oid}

  def set_merged_command_set(command, command_set), do: %{command | merged_command_set: command_set}

  def set_raw_input(command, input), do: %{command | raw_input: input}
end

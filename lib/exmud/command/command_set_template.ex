defmodule Exmud.CommandSetTemplate do
  @moduledoc """
  This template is the contract between `Exmud` and the consuming application, when it comes to command sets.
  """

  @doc """
  Initialize a new command set.

  All custom logic to build a command set takes place here. In most cases this involves creating a command set object
  and adding the desired commands.

  The 'init' method is called with the id of the object that the command set belongs to, allowing for advanced
  implementations to customize the commands returned based on object attributes, or even from information gleaned from
  an object's environment.

  Note that this method will be called relatively often. For example if a command set were attached to an object a
  player had puppeted, the init method for that command set would be called every time the player submitted a command.
  For a command set that is visible to all other objects around it, a fountain in a busy thoroughfare for example, it
  would be called every time any player submitted a command in that room. This is so the individual command sets that
  the player has access to in their current context can be combined into a final command set against which their
  submitted command can be matched.

  Due to this, the lighter weight the callback function can be the better.
  """
  @callback init(object) :: {:ok, command_set_template} | {:error, reason}

  @typedoc "The id of the object that the command set is being built for."
  @opaque object :: term

  @typedoc "A populated command set template struct."
  @type command_set_template :: %Exmud.CommandSetTemplate{}

  @typedoc "The reason for the failure."
  @type reason :: term


  #
  # Struct Definition
  #


  defstruct allow_duplicates: false,
            commands: MapSet.new(),
            merge_type: :union,
            merge_type_overrides: %{},
            priority: 0


  #
  # API
  #


  # Commands

  @doc false
  def add_command(command_set_template, command) do
    %{command_set_template | commands: MapSet.put(command_set_template.commands, command)}
  end

  @doc false
  def has_command?(command_set_template, command), do: MapSet.member?(command_set_template.commands, command)

  @doc false
  def remove_command(command_set_template, command) do
    %{command_set_template | commands: MapSet.delete(command_set_template.commands, command)}
  end

  # Merge type overrides

  @doc false
  def add_override(command_set_template, key, merge_type) do
    %{command_set_template | merge_type_overrides: Map.put(command_set_template.merge_type_overrides, key, merge_type)}
  end

  @doc false
  def has_override?(command_set_template, key), do: Map.has_key?(command_set_template.merge_type_overrides, key)

  @doc false
  def remove_override(command_set_template, key) do
    %{command_set_template | merge_type_overrides: Map.delete(command_set_template.merge_type_overrides, key)}
  end

  # Other command set manipulation

  @doc false
  def new, do: %Exmud.CommandSetTemplate{}

  @doc false
  def set_allow_duplicates(command_set_template, maybe), do: %{command_set_template | allow_duplicates: maybe}

  @doc false
  def set_merge_type(command_set_template, merge_type), do: %{command_set_template | merge_type: merge_type}

  @doc false
  def set_priority(command_set_template, priority), do: %{command_set_template | priority: priority}
end
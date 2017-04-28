defmodule Exmud.CommandTemplate do
  @moduledoc """
  This template is the contract between `Exmud` and the consuming application, when it comes to commands.

  When a command is registered with `Exmud`, the values in this template are used to determine how to
  index the module.
  """

  defstruct(
    aliases: MapSet.new(), # A command may have any number of aliases that it also matches against.
    auto_help: true, # Extract and display help documentation to player in case of command processing failure.
    callback_module: nil, # The module the engine will call when this command is matched.
    help_category: "General", # A path to where the help documentation will be found. A `nil` value means no help docs.
    key: nil, # The primary key that, along with the aliases, is used to determine what to execute.
    object: nil # The object that the command belongs to. Used by the engine when processing command strings.
  )

  @doc false
  def new, do: %Exmud.CommandTemplate{}

  # Alias functions

  @doc false
  def add_alias(template, a) do
    %{template | aliases: MapSet.put(template.aliases, a)}
  end

  @doc false
  def has_alias?(template, a), do: MapSet.member?(template.aliases, a)

  @doc false
  def remove_alias(template, a), do: %{template | aliases: MapSet.delete(template.aliases, a)}

  # Setters

  @doc false
  def set_callback_module(template, callback_module), do: %{template | callback_module: callback_module}

  @doc false
  def set_auto_help(template, auto_help), do: %{template | auto_help: auto_help}

  @doc false
  def set_help_category(template, category), do: %{template | help_category: category}

  @doc false
  def set_key(template, key), do: %{template | key: key}
end
defmodule Exmud.CommandTemplate do
  @moduledoc """
  This template is the contract between `Exmud` and the consuming application, when it comes to commands.

  When a command is registered with `Exmud`, the values in this template are used to determine how to
  index the module.
  """

  defstruct(
    aliases: MapSet.new(), # A command may have any number of aliases that it also matches against.
    auto_help: true, # Extract and display help documentation to player in case of command processing failure.
    help_category: "General", # A path to where the help documentation will be found. A `nil` value means no help docs.
    key: nil, # The primary key that, along with the aliases, is used to determine what to execute.
  )

  def new, do: %Exmud.CommandTemplate{}

  def add_alias(template, a) do
    %{template | aliases: MapSet.put(template.aliases, a)}
  end

  def get_aliases(template), do: template.aliases

  def has_alias?(template, a), do: MapSet.member?(template.aliases, a)

  def get_auto_help(template), do: template.auto_help

  def set_auto_help(template, auto_help), do: %{template | auto_help: auto_help}

  def remove_alias(template, a) do
    %{template | aliases: MapSet.delete(template.aliases, a)}
  end

  def get_help_category(template), do: template.help_category

  def set_help_category(template, category), do: %{template | help_category: category}

  def get_key(template, key), do: template.key

  def set_key(template, key), do: %{template | key: key}
end
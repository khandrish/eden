defmodule Exmud.CommandTemplate do
  @moduledoc """
  This template is the contract between `Exmud` and the consuming application, when it comes to commands.

  When a command is registered with `Exmud`, the values in this template are used to determine how to index the module.
  """

  defstruct(
    aliases: MapSet.new(), # A command may have any number of aliases that it also matches against.
    auto_help: true, # Extract and display help documentation to player in case of command processing failure.
    parser: nil, # The module the engine will call to parse the arg string.
    handler: nil, # The module the engine will call when this command is matched.
    help_category: "General", # A path to where the help documentation will be found.
    key: nil, # The primary key that, along with the aliases, is used to determine what to execute.
    locks: [],
    object: nil # The object that the command belongs to. Used by the engine when processing command strings.
  )

  def init(object, handler) do
    new()
    |> set_handler(handler)
    |> set_object(object)
    |> handler.init()
  end

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

  # Lock functions

  @doc false
  #def add_lock(template, lock) do
  #  %{template | aliases: MapSet.put(template.locks, lock)}
  #end

  @doc false
  #def has_lock?(template, lock), do: MapSet.member?(template.locks, lock)

  @doc false
  #def remove_lock(template, lock), do: %{template | aliases: MapSet.delete(template.locks, lock)}

  # Setters

  @doc false
  def set_auto_help(template, auto_help), do: %{template | auto_help: auto_help}

  @doc false
  def set_handler(template, handler), do: %{template | handler: handler}

  @doc false
  def set_help_category(template, category), do: %{template | help_category: category}

  @doc false
  def set_key(template, key), do: %{template | key: key}

  @doc false
  def set_object(template, object), do: %{template | object: object}

  @doc false
  def set_parser(template, parser), do: %{template | parser: parser}
end
defmodule Exmud.Game.Contributions.Core.Template.Character do
  @moduledoc """
  A Character belongs to a Player, and as such a Player must be provided when spawning a new Character.

  The minimum config that must be provided is:
    %{
      player_id: 123,
      name: "Gimli"
    }
  """
  use Exmud.Engine.Template
  alias Exmud.Engine.Template.CommandSetEntry
  alias Exmud.Engine.Template.ComponentEntry
  alias Exmud.Engine.Template.LockEntry

  @doc false
  @impl true
  @spec command_sets(Map.t()) :: {:ok, [CommandSetEntry.t()]}
  def command_sets(config) do
    {:ok,
     [
       %CommandSetEntry{
         callback_module: Exmud.Engine.Component.CharacterCommandSet,
         config: config
       }
     ]}
  end

  @doc false
  @impl true
  @spec components(Map.t()) :: {:ok, [ComponentEntry.t()]}
  def components(config) do
    {:ok,
     [
       %ComponentEntry{
         callback_module: Exmud.Engine.Component.CharacterComponent,
         config: config
       }
     ]}
  end

  @doc false
  @impl true
  @spec locks(Map.t()) :: {:ok, [LockEntry.t()]}
  def locks(config) do
    {:ok,
     [
       %Exmud.Engine.Template.LockEntry{
         callback_module: Exmud.Engine.Lock.CharacterPuppetLock,
         config: %{"player_id" => config["player_id"]},
         access_type: "puppet"
       }
     ]}
  end

  @doc false
  @impl true
  @spec tags(Map.t()) :: {:ok, [TagEntry.t()]}
  def tags(_config) do
    {:ok,
     [
       %Exmud.Engine.Template.TagEntry{
         category: engine_tag_category(),
         tag: character_tag()
       }
     ]}
  end
end

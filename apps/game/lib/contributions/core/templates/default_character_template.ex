defmodule Exmud.Engine.Template.DefaultCharacterTemplate do
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
  @spec command_sets( Map.t() ) :: [ CommandSetEntry.t() ]
  def command_sets( config ) do
    [
      %CommandSetEntry{
        callback_module: Exmud.Engine.Component.DefaultCharacterCommandSet,
        config: config
      }
    ]
  end

  @doc false
  @impl true
  @spec components( Map.t() ) :: [ ComponentEntry.t() ]
  def components( config ) do
    [
      %ComponentEntry{
        callback_module: Exmud.Engine.Component.BasicCharacterComponent,
        config: config
      }
    ]
  end

  @doc false
  @impl true
  @spec locks( Map.t() ) :: [ LockEntry.t() ]
  def locks( _config ) do
    [
      %Exmud.Engine.Template.LockEntry{
        callback_module: Exmud.Engine.Lock.DefaultCharacterPuppetLock,
        config: %{ "player_id" => config["player_id"] },
        access_type: "puppet"
      }
    ]
  end

  @doc false
  @impl true
  @spec tags( Map.t() ) :: [ TagEntry.t() ]
  def tags( _config ) do
    [
      %Exmud.Engine.Template.TagEntry{
        category: engine_tag_category(),
        tag: character_tag()
      }
    ]
  end
end

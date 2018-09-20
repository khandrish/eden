defmodule Exmud.Engine.Component.DefaultCharacterComponent do
  @moduledoc """
  A Character is a Game Object that acts as the Player's avatar within the game world.

  A Character component has the following required fields:
    - name
    - owner

  The 'name' field represents the unique name of the character.
  """
  use Exmud.Engine.Component

  @spec populate( integer, %{ required( atom() ) => term } ) :: :ok | :error
  def populate( object_id, config ) do
    Attribute.put( object_id, __MODULE__, "owner", config.player )
    Attribute.put( object_id, __MODULE__, "name", config.name )
  end

  #
  # Attributes
  #

  @doc """
  The Game Object which owns the character. This is usually a Player.
  """
  def owner, do: "owner"

  @doc """
  Each character has a unique name in the engine.
  """
  def name, do: "name"
end

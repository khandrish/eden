defmodule Exmud.Engine.Component.BasicCharacterComponent do
  @moduledoc """
  A Character is a Game Object that acts as the Player's avatar within the game world.

  A Character component has the following required fields:
    - name
    - player_id

  The 'name' field represents the unique name of the character.
  """
  use Exmud.Engine.Component

  @spec populate( integer, %{ required( String.t() ) => term } ) :: :ok | { :error, :character_name_in_use }
  def populate( object_id, config ) do
    if Attribute.exists?( __MODULE__, name(), config[ name() ]) do
      { :error, :character_name_in_use }
    else
      :ok = Attribute.put( object_id, __MODULE__, player_id(), config[ player_id() ] )
      :ok = Attribute.put( object_id, __MODULE__, name(), config[ name() ] )
    end
  end

  #
  # Attributes
  #

  @doc """
  The Player Object which owns the Character.
  """
  @spec player_id :: String.t()
  def player_id, do: "player_id"

  @doc """
  Each Character has a unique name in the Engine.
  """
  @spec name :: String.t()
  def name, do: "name"
end

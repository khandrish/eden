defmodule Exmud.Engine.Lock.DefaultCharacterPuppetLock do
  @moduledoc """
  Allows puppeting of a Character by its owning Player
  """
  use Exmud.Engine.Lock

  @doc false
  @impl
  def check( _target_object, accessing_object, lock_config ) when is_map( lock_config ) do
    Map.get( lock_config, "owner" ) == accessing_object
  end
end

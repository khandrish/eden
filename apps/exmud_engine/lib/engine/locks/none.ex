defmodule Exmud.Engine.Lock.None do
  @moduledoc """
  This lock performs no checks, but instead fails immediately.
  """
  use Exmud.Engine.Lock

  @doc false
  @impl true
  def check( _target_object, _accessing_object, _lock_config ), do: false
end

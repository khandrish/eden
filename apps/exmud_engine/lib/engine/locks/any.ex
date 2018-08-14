defmodule Exmud.Engine.Lock.Any do
  @moduledoc """
  This lock performs no checks, but instead allows the lock check to pass immediately.
  """

  @doc false
  def check( _target_object, _accessing_object, _lock_config ), do: true
end

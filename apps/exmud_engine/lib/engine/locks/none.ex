defmodule Exmud.Engine.Lock.None do
  @moduledoc """
  This lock performs no checks, but instead fails immediately.
  """

  @doc false
  def check( _target_object, _accessing_object, _lock_config ), do: false
end

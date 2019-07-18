defmodule Exmud.Contributions.Core.Lock.Any do
  @moduledoc """
  No-op lock which allows the lock check to pass immediately.
  """
  # use Exmud.Engine.Lock

  @doc false
  # @impl true
  def check(_target_object, _accessing_object, _lock_config), do: true
end

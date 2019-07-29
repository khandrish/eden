defmodule Exmud.Contributions.Core.Lock.Any do
  @moduledoc """
  No-op lock which allows the lock check to pass immediately.

  Configuration: None
  """
  # use Exmud.Engine.Lock

  @doc false
  # @impl true
  def check(_target_object, _accessing_object, _lock_config), do: true

  def config_schema, do: %{"type" => "object", "properties" => %{}, "additionalProperties" => false}

  def default_config, do: %{}
end

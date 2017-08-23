defmodule Exmud.Engine.Utils do
  @moduledoc false

  import Exmud.Common.Utils

  def cache, do: :exmud_engine_cache
  def system_registry, do: :exmud_engine_system_registry

  def engine_cfg(key), do: cfg(:exmud_engine, key)
end
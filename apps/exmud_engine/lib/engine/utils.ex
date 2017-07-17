defmodule Exmud.Engine.Utils do
  @moduledoc false

  import Exmud.Common.Utils

  def cache, do: engine_cfg(:cache)
  def system_registry, do: engine_cfg(:system_registry)

  def engine_cfg(key), do: cfg(:exmud_engine, key)
end
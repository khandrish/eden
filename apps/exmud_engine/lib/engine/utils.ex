defmodule Exmud.Engine.Utils do
  @moduledoc false

  import Exmud.Common.Utils

  def cache, do: engine_cfg(:cache)

  def engine_cfg(key), do: cfg(:exmud_engine, key)
end
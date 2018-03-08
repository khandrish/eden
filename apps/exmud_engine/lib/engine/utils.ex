defmodule Exmud.Engine.Utils do
  @moduledoc false

  import Exmud.Common.Utils

  def cache, do: :exmud_engine_cache
  def system_registry, do: :exmud_engine_system_registry
  def script_registry, do: :exmud_engine_script_registry

  def engine_cfg(key), do: cfg(:exmud_engine, key)

  def unpack_term(<<31 :: size(8), 139 :: size(8), _rest :: binary>> = state), do: deserialize(:zlib.gunzip(state))

  def unpack_term(state), do: deserialize(state)

  @compression_threshold_bytes cfg(:exmud_engine, :byte_size_to_compress)
  def pack_term(state) do
    bin = :erlang.term_to_binary(state)

    if byte_size(bin) >= @compression_threshold_bytes do
      :zlib.gzip(bin)
    else
      bin
    end
  end
end
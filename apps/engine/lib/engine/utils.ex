defmodule Exmud.Engine.Utils do
  @moduledoc false

  alias Exmud.Engine.Repo
  import Exmud.Common.Utils

  def cache, do: :exmud_engine_cache

  def engine_cfg( key ), do: cfg( :exmud_engine, key )

  # Check to see if the gzip header is present, and if it is gunzip first.
  def unpack_term( << 31::size( 8 ), 139::size( 8 ), 8::size( 8 ), _rest::binary >> = state ) do:
    try do
      state
      |> :zlib.gunzip()
      |> :erlang.binary_to_term()
    rescue
      :data_error ->
        :erlang.binary_to_term( state )
    end
  end

  def unpack_term( term ), do: :erlang.binary_to_term( term )

  @compression_threshold_bytes cfg( :exmud_engine, :byte_size_to_compress )
  def pack_term( term ) do
    bin = :erlang.term_to_binary( term )

    if byte_size( bin ) >= @compression_threshold_bytes do
      :zlib.gzip( bin )
    else
      bin
    end
  end

  def wrap_callback_in_transaction( callback ) do
    Repo.transaction( fn ->
      try do
        callback.()
      rescue
        error -> Repo.rollback( error )
      end
    end)
    |> elem( 1 )
  end
end

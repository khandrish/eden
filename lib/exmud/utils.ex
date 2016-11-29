defmodule Exmud.Utils do
  @moduledoc false
  @doc false

  def cfg(key), do: Application.get_env(:exmud, key)
  def engine_cfg(key), do: Application.get_env(:exmud, :engine)[key]
  
  def deserialize(term), do: :erlang.binary_to_term(term)
  def serialize(term), do: :erlang.term_to_binary(term)

end

defmodule Exmud.Utils do
  @moduledoc false

  alias Exmud.Repo

  def cfg(key), do: Application.get_env(:exmud, key)
  def engine_cfg(key), do: Application.get_env(:exmud, :engine)[key]

  def find(model, key) do
    Repo.get_by(model, key: key)
  end

  def deserialize(term), do: :erlang.binary_to_term(term)
  def serialize(term), do: :erlang.term_to_binary(term)

  def normalize_ecto_errors(errors), do: Enum.map(errors, fn({key, {error, _}}) -> {key, error} end)

  def normalize_ok_result({:ok, _}, desired_result), do: {:ok, desired_result}
  def normalize_ok_result({:error, changeset}, _offender), do: {:error, normalize_ecto_errors(changeset.errors)}
end

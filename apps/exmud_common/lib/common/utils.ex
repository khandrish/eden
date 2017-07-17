defmodule Exmud.Common.Utils do
  @moduledoc false

  def cfg(first_key, second_key), do: Application.get_env(first_key, second_key)

  def deserialize(term), do: :erlang.binary_to_term(term)
  def serialize(term), do: :erlang.term_to_binary(term)

  def normalize_ecto_errors(errors), do: Enum.map(errors, fn({key, {error, _}}) -> {key, error} end)

  def normalize_multi_result({:ok, results}, desired_result), do: {:ok, results[desired_result]}
  def normalize_multi_result({:error, _, error, _}, _), do: {:error, error}

  def normalize_repo_result({:ok, _}, desired_result), do: {:ok, desired_result}
  def normalize_repo_result({:error, changeset}, _), do: {:error, normalize_ecto_errors(changeset.errors)}

  def via(registry, key), do: {:via, Registry, {registry, key}}
end
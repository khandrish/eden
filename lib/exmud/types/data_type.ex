defmodule Exmud.Type.Data do
  @moduledoc false

  @behaviour Ecto.Type
  def type, do: :binary

  # Provide custom casting rules
  # Cast binary into Elixir terms to be used at runtime
  def cast(data) when is_binary(data) do
    {:ok, :erlang.binary_to_term(data)}
  end

  # Everything else is a failure
  def cast(_), do: :error

  # When loading data from the database we are guaranteed to receive a binary and we will just need to turn it into a
  # term safely.
  def load(data) when is_binary(data) do
    {:ok, :erlang.binary_to_term(data)}
  end

  # When dumping data to the database any term will work.
  def dump(data),
    do: {:ok, :erlang.term_to_binary(data)}
end

defmodule Exmud.Type.CallbackModule do
  @moduledoc false

  @behaviour Ecto.Type
  def type, do: :string

  # Provide custom casting rules
  # Cast strings into a Module to be used at runtime
  def cast(callback_module) when is_binary(callback_module) do
    {:ok, String.to_existing_atom(callback_module)}
  end

  # Assume atoms are actually the name of a callback module
  def cast(callback_module) when is_atom(callback_module) do
    {:ok, callback_module}
  end

  # Everything else is a failure
  def cast(_), do: :error

  # When loading data from the database we are guaranteed to receive a string and we will just need to turn it into an
  # atom safely.
  def load(callback_module) when is_binary(callback_module) do
    {:ok, String.to_existing_atom(callback_module)}
  end

  # When dumping data to the database an atom if expected but any value could be provided so guard against that.
  def dump(callback_module) when is_atom(callback_module),
    do: {:ok, Atom.to_string(callback_module)}

  def dump(_), do: :error
end

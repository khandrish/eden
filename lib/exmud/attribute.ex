defmodule Exmud.Attribute do
  @moduledoc """
  An `Exmud.GameObject` can have an arbitrary number of attributes with
  arbitrary data. The data is serialized before going into the database
  which greatly simplifies storage and retrieval at the cost of being unable
  to index or search on attribute values.
  
  Manipulation and inspection of attributes on objects is performed via this
  module, while listing of `Exmud.GameObject`'s should be performed via that
  module.
  """
  
  alias Exmud.Repo
  alias Exmud.Schema.Attribute
  alias Exmud.Schema.GameObject
  import Ecto.Query
  import Exmud.Utils
  
  #
  # API
  #
  
  def add(oid, key, data) do
    args = %{data: :erlang.term_to_binary(data),
             key: key,
             oid: oid}
    Repo.insert(Attribute.changeset(%Attribute{}, args))
    |> normalize_noreturn_result()
  end
  
  def get(oid, key) do
    case Repo.one(attribute_query(oid, key)) do
      nil -> {:error, :no_such_attribute}
      object ->
        {:ok, :erlang.binary_to_term(object.data)}
    end
  end
  
  def has?(oid, key) do
    case Repo.one(attribute_query(oid, key)) do
      nil -> {:ok, false}
      object -> {:ok, true}
    end
  end
  
  def list(attributes) do
    Exmud.GameObject.list(attributes: List.wrap(attributes))
  end
  
  def remove(oid, key) do
    Repo.delete_all(attribute_query(oid, key))
    |> case do
      {1, _} -> :ok
      {0, _} -> {:error, :no_such_attribute}
      _ -> {:error, :unknown}
    end
  end
  
  def update(oid, key, data) do
    args = %{data: data,
             key: key,
             oid: oid}
    Repo.update(Attribute.changeset(%Attribute{}, args))
    |> normalize_noreturn_result()
  end
  
  
  #
  # Private functions
  #
  
  
  defp attribute_query(oid, key) do
    from attribute in Attribute,
      where: attribute.oid == ^oid,
      where: attribute.key == ^key
  end
end
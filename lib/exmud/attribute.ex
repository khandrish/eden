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
  
  def add(oid, name, data) do
    args = %{data: :erlang.term_to_binary(data),
             name: name,
             oid: oid}
    Repo.insert(Attribute.changeset(%Attribute{}, args))
    |> normalize_noreturn_result()
  end
  
  def get(oid, name) do
    case Repo.one(find_attribute_query(oid, name)) do
      nil -> {:error, :no_such_game_object}
      object ->
        if length(object.attributes) == 1 do
          {:ok, :erlang.binary_to_term(hd(object.attributes).data)}
        else
          {:error, :no_such_attribute}
        end
    end
  end
  
  def has?(oid, name) do
    case Repo.one(find_attribute_query(oid, name)) do
      nil -> {:error, :no_such_game_object}
      object -> {:ok, length(object.attributes) == 1}
    end
  end
  
  def remove(oid, name) do
    Repo.delete_all(
      from attribute in Attribute,
        where: attribute.oid == ^oid,
        where: attribute.name == ^name
    )
    |> case do
      {1, _} -> :ok
      {0, _} -> {:error, :no_such_attribute}
      _ -> {:error, :unknown}
    end
  end
  
  def update(oid, name, data) do
    args = %{data: data,
             name: name,
             oid: oid}
    Repo.update(Attribute.changeset(%Attribute{}, args))
    |> normalize_noreturn_result()
  end
  
  
  #
  # Private functions
  #
  
  
  defp find_attribute_query(oid, name) do
    from object in GameObject,
      left_join: attribute in assoc(object, :attributes), on: object.id == attribute.oid,
      where: object.id == ^oid or attribute.name == ^name and object.id == ^oid,
      preload: [attributes: attribute]
  end
end
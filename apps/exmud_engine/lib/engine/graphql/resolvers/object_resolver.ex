defmodule Exmud.Engine.Graphql.Resolver.ObjectResolver do
  alias Exmud.Engine.Object

  def many(%{key: key}, _info) do
    Object.get(key)
  end

  def one(%{id: id}, _info) do
    Object.get(id)
  end

  def query(%{object_query: object_query}, _info) do
    Object.query(object_query)
  end
end

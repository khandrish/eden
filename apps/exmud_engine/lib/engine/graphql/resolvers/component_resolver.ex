defmodule Exmud.Engine.Graphql.Resolver.ComponentResolver do
  alias Exmud.Engine.Component

  def many(%{component: component}, _info) do
    Component.get(component)
  end

  def many(%{object_id: id}, _info) do
    Component.get(id)
  end

  def one(%{object_id: object_id, component: component}, _info) do
    Component.get(object_id, component)
  end
end

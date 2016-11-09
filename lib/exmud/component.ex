defmodule Exmud.Component do
  alias Exmud.Db

  def add(entity, component, args \\ %{}) do
    Db.transaction(fn ->
      entity
      |> Db.write(component, __MODULE__, true)
    end)
    component.init(entity, args)
    entity
  end

  def find_with_value(component, key, fun) do
    Db.transaction(fn ->
      Db.find_with_all(component, key, fun)
    end)
  end
end

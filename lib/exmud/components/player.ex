defmodule Exmud.Component.Player do
  alias Exmud.Db
  require Logger

  def init(entity, args) do
    Db.transaction(fn ->
      entity
      |> Db.write(__MODULE__, :puppets, [])
      |> Db.write(__MODULE__, :name, args.name)
    end)
  end

  def find(names) when is_list(names) do
    Db.transaction(fn ->
      names
      |> Enum.map(fn(name) ->
        {name, Db.find_with_all(__MODULE__, :name, &(&1 === name))}
      end)
    end)
  end

  def find(name) do
    find([name])
    |> hd()
    |> elem(1)
  end
end

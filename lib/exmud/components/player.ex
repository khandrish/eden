defmodule Exmud.Component.Player do
  alias Exmud.Db
  require Logger

  def init(entity, _args) do
    Logger.debug("Initializing #{__MODULE__} of `#{entity}`")
    Db.transaction(fn ->
      entity
      |> Db.write(__MODULE__, "puppets", [])
    end)
  end
end

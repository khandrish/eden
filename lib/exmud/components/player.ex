defmodule Exmud.Component.Player do
  alias Exmud.Entity
  require Logger

  def init(entity) do
    Logger.debug("Initializing #{__MODULE__} of `#{entity}`")
    entity
    |> Entity.add_key(__MODULE__, "puppets", nil)
  end
end

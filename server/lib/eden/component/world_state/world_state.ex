defmodule Eden.Component.WorldState do
  @behaviour Eden.Component

  alias Eden.EntityManager, as: EM
  alias Calendar.DateTime, as: DT


  def init(entity) do
    EM.add_component(entity, __MODULE__)
    |> EM.put(__MODULE__, "created", now)
    |> EM.put(__MODULE__, "runtime", 0)
    |> EM.put(__MODULE__, "last_start", now)
  end

  def name do
    "world_state"
  end

  def get_json(entity) do
    EM.get_all_component_data(entity, __MODULE__)
    # TODO: Turn into json
  end
end
defmodule Eden.EngineFsm do
  alias Eden.Component.WorldState, as: WS
  alias Eden.EntityManager, as: EM
  use Fsm, initial_state: :idle, initial_data: %{entity: nil}

  defstate running do
    defevent stop, data: %{entity: entity} do
      # update entity
      response(:ok, :stopped)
    end
  end

  defstate stopped do
    defevent start, data: %{entity: nil} = state do
      EM.load_all_entities
      entity = EM.create_with_or_return(WS)

      response(:ok, :running, Map.update!(state, :entity, entity))
    end

    defevent start, data: %{entity: entity} do
      # update entity
      response(:ok, :running)
    end
  end

  defevent _, do: response(:error)
end
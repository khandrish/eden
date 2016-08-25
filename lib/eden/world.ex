defmodule Eden.World do
  use Fsm, initial_state: :pending, initial_data: %{entity: nil}

  defstate pending do
    defevent initialize(_options) do
      # create an entity with the components needed to hold the data for a world
      # save the id of the entity in the data
      respond(:ok, :stopped, %{entity: 1})
    end
  end

  defstate running do
    defevent stop, data: %{entity: _entity} do
      # update entity
      respond(:ok, :stopped)
    end
  end

  defstate stopped do
    defevent start(_name), data: %{entity: nil} = state do
      # This may or may not be the first time this world is being run
      # Do a search for entities with a specific signature, if none exist initialize the world

      respond(:ok, :running, state)
    end

    defevent start(_name), data: %{entity: _entity} do
      # update entity
      respond(:ok, :running)
    end
  end

  defevent _, do: respond(:error)
end
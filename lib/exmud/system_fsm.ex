defmodule Exmud.SystemFsm do
  use Fsm, initial_state: :created, initial_data: %{}

  defstate created do
    defevent initialize(module, args) do
      state = module.initialize(args)
      next_state(:stopped, %{state: state, module: module})
    end
  end

  defstate running do
    defevent message(message), data: %{state: state, module: module} = data do
      {response, state} = module.handle_message(message, state)
      respond(response, :running, Map.put(data, :state, state))
    end

    defevent stop(args), data: %{state: state, module: module} = data do
      state = module.stop(args, state)
      next_state(:stopped, Map.put(data, :state, state))
    end
  end

  defstate stopped do
    defevent start(args), data: %{state: state, module: module} = data do
      state = module.start(args, state)
      next_state(:running, Map.put(data, :state, state))
    end

    defevent terminate(), data: %{state: state, module: module} = data do
      module.terminate(state)
      next_state(:created, Map.put(data, :state, %{}))
    end
  end
end

defmodule Exmud.CommandProcessorSupervisor do

  use ConsumerSupervisor

  def start_link() do
    children = [
      worker(CommandProcessor, [], restart: :temporary)
    ]

    ConsumerSupervisor.start_link(children, strategy: :one_for_one,
                                            subscribe_to: [{Producer, max_demand: 50}])
  end
end
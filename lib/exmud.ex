defmodule Exmud do
  alias Exmud.Callback
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      supervisor(Task.Supervisor, [[name: Exmud.TaskSupervisor]]),
      supervisor(Registry, [:unique, :player_session_registry]),
      supervisor(Exmud.SystemSup, []),
      supervisor(Exmud.CommandProcessorSup, []),
      supervisor(Exmud.PlayerSessionSup, []),
      worker(Exmud.Repo, []),
      worker(Exmud.Cache, []),
    ]

    opts = [strategy: :one_for_one, name: Exmud.Supervisor]

    case Supervisor.start_link(children, opts) do
      {:ok, _pid} = result ->
        Callback.register("CMD_NO_MATCH", Exmud.Command.Handler.NoMatch)
        Callback.register("CMD_BLANK_INPUT", Exmud.Command.Handler.BlankInput)
        Callback.register("CMD_MULTI_MATCH", Exmud.Command.Handler.MultiMatch)
        Callback.register("command_context", Exmud.Command.Context.Default)
        Callback.register("command_string_preprocessors", [Exmud.Command.Preproccessor.Trim])
        Callback.register("command_string_validators", [])
        Callback.register("command_processor", Exmud.Command.Processor.Default)

        result
      error ->
        error
    end
  end
end

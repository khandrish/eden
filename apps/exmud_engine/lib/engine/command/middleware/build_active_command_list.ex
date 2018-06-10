defmodule Exmud.Engine.Command.Middleware.BuildActiveCommandList do
  @moduledoc """
  This default implementation considers the caller to be the whole context, doing nothing more than building the active list of Commands from that.
  """

  @behaviour Exmud.Engine.Command.Middleware

  alias Exmud.Engine.CommandSet

  def execute(execution) do
    {:ok, %{execution | command_list: CommandSet.build_active_command_list(execution.caller, execution.caller)}}
  end
end

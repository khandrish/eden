defmodule Exmud.Command.Handler.Look do
  @moduledoc """
  The look handler.
  """

  alias Exmud.CommandTemplate
  require Logger
  @behaviour Exmud.Command
  @behaviour Exmud.Command.Handler

  @doc false
  def handle(command) do
    Logger.debug("Handler running with arguments: #{inspect(command)}")
    {:ok, nil}
  end

  @doc false
  def initialize(command_template) do
    command_template
    |> CommandTemplate.set_key("CMD_MULTI_MATCH")
    |> CommandTemplate.set_auto_help(false)
    |> CommandTemplate.set_parser(false)
  end
end
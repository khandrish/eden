defmodule Exmud.PlayerSessionOutputHandler do
  use GenEvent

  def init(handler_fun) do
    {:ok, handler_fun}
  end

  def handle_event(event, handler_fun) do
    handler_fun.(event)
    {:ok, handler_fun}
  end
end

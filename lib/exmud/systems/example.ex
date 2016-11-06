defmodule Exmud.System.Example do
  @moduledoc """
  A barebones example of a system, primarily used for testing.
  """

  def handle_message(message, state) do
    {message, state}
  end

  def initialize(_args) do
    %{}
  end

  def start(_args, state) do
    state
  end

  def stop(_args, state) do
    state
  end

  def terminate(_state) do
    :ok
  end
end

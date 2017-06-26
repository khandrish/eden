defmodule Exmud.Session do
  @moduledoc """
  A Session is created when an authenticated player connects to the Engine.

  A Session coordinates the flow of messages to and from the player, enabling the Engine to stay unaware of and largely
  immune to the impact of coordination and transmission of messages.
  """

  def active? do
    :ok
  end

  def start do
    :ok
  end

  def stop do
    :ok
  end
end

defmodule Exmud.Engine do
  @moduledoc """
  The Engine is what drives the game world forward. It coordinates calling into the systems/commands/callbacks that have
  been registered, and making sure that database interactions are appropriately isolated from other concurrent parts of
  the Engine. The Engine does not actually start until explicitely told to.
  """

  alias Exmud.Engine.MasterControl, as: MC
  alias Exmud.Game.Schema

  def restart do
    with {:ok, _} <- stop(),
      do: start()
  end

  def start do
    GenServer.call(MC, :start, :infinity)
  end

  def stop do
    GenServer.call(MC, :stop, :infinity)
  end
end

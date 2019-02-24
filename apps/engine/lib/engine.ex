defmodule Exmud.Engine do
  @moduledoc """
  The Engine is what drives the game world forward. It coordinates calling into the systems/commands/callbacks that have
  been registered, and making sure that database interactions are appropriately isolated from other concurrent parts of
  the Engine.

  At the same time, the Engine itself is passive in that it does nothing that is not triggered by an external call.
  """
end

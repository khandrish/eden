defmodule Exmud.Game.Command.Middleware.BuildActiveCommandSet do
  @moduledoc """
  Bulding the active command set of an Object is a multistep process.

  First the context must be gathered, which is the set of all Objects which will be searched for Command Sets to merge together.

  Next the command sets will be split into groups based on priority and further broken down by type of merge to be performed. These will then be merged together until a final, single command set remains which can be used in the rest of the pipeline.
  """

  @behaviour Exmud.Engine.Command.Middleware

  def execute() do

  end
end

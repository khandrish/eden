defmodule Exmud.Engine.Test.Middleware.Echo do
  @moduledoc """
  Executes the Echo test Command
  """

  @behaviour Exmud.Engine.Command.Middleware

  def execute(context) do
    Exmud.Engine.Test.Command.Echo.execute(context)
  end
end

defmodule Exmud.Engine.Test.Command.Echo do
  @moduledoc """
  Echoes the text following the 'echo' command back to the player via an '%Exmud.Engine.Event{}'.
  """
  use Exmud.Engine.Command

  @impl true
  def key(_context), do: "echo"

  @impl true
  def execute(context) do
    {:ok,
     Exmud.Engine.Command.ExecutionContext.put(
       context,
       :echo,
       List.last(String.split(context.raw_input))
     )}
  end
end

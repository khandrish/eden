defmodule Exmud.Command.Context.Caller do
  @moduledoc false

  @behaviour Exmud.Command.Context

  def define(subject), do: List.wrap(subject)
end

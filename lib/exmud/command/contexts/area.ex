defmodule Exmud.Command.Context.Area do
  @moduledoc false

  @behaviour Exmud.Command.Context

  def define(subject), do: List.wrap(subject)
end

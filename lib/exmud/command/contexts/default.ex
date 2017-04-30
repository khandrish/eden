defmodule Exmud.Command.Context.Default do
  @moduledoc false

  @behaviour Exmud.Command.Context

  def run(subject), do: [subject]
end

defmodule Exmud.Engine.Template.LinkEntry do
  @moduledoc false

  @enforce_keys [ :to, :type, :config ]
  defstruct [ :to, :type, :config ]
  @type t :: %Exmud.Engine.Template.LinkEntry{
    to: integer(),
    type: String.t(),
    config: term()
  }
end

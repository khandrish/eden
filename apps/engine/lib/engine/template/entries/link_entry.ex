defmodule Exmud.Engine.Template.LinkEntry do
  @moduledoc false

  @enforce_keys [ :to, :type, :state ]
  defstruct [ :to, :type, :state ]
  @type t :: %Exmud.Engine.Template.LinkEntry{
    to: integer(),
    type: String.t(),
    state: term()
  }
end

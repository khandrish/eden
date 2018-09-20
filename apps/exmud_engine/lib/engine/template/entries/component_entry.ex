defmodule Exmud.Engine.Template.ComponentEntry do
  @moduledoc false

  @enforce_keys [ :callback_module, :config ]
  defstruct [ :callback_module, :config ]
  @type t :: %Exmud.Engine.Template.ComponentEntry{
    callback_module: module(),
    config: term()
  }
end

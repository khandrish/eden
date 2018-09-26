defmodule Exmud.Engine.Template.ScriptEntry do
  @moduledoc false

  @enforce_keys [ :callback_module, :config ]
  defstruct [ :callback_module, :config ]
  @type t :: %Exmud.Engine.Template.ScriptEntry{
    callback_module: module(),
    config: term()
  }
end

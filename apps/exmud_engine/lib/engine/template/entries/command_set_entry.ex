defmodule Exmud.Engine.Template.CommandSetEntry do
  @moduledoc false

  @enforce_keys [ :callback_module, :config ]
  defstruct [ :callback_module, :config ]
  @type t :: %Exmud.Engine.Template.CommandSetEntry{
    callback_module: module(),
    config: term()
  }
end

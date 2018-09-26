defmodule Exmud.Engine.Template.LockEntry do
  @moduledoc false

  @enforce_keys [ :access_type, :callback_module, :config ]
  defstruct [ :access_type, :callback_module, :config ]
  @type t :: %Exmud.Engine.Template.LockEntry{
    access_type: String.t(),
    callback_module: module(),
    config: term()
  }
end

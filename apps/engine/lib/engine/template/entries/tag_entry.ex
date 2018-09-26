defmodule Exmud.Engine.Template.TagEntry do
  @moduledoc false

  @enforce_keys [ :category, :tag ]
  defstruct [ :category, :tag ]
  @type t :: %Exmud.Engine.Template.TagEntry{
    category: String.t(),
    tag: String.t()
  }
end

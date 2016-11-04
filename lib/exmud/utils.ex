defmodule Exmud.Utils do
  @moduledoc false
  @doc false

  def cfg(key), do: Application.get_env(:exmud, key)

end

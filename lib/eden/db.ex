defmodule Eden.Db do
  @moduledoc """
  Abstracts away the reliance on Amnesia by providing a transaction wrapper.
  """
  use Amnesia

  def transaction(block) do
    Amnesia.transaction(block)
  end
end
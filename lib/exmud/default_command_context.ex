defmodule Exmud.DefaultCommandContext do
  @defmodule false

  # Given the ID of an object, gather the other objects which make up its
  # context. This context is then used for checking against a players input
  # to determine which command(s), if any, match.
  def build(object_id) do
    GameObject.list()
  end
end

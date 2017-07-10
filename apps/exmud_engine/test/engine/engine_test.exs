defmodule Exmud.Engine.Test.EngineTest do
  alias Exmud.Engine
  use Exmud.Engine.Test.DBTestCase
  doctest Exmud.Engine

  @tag engine: true
  test "configure" do
    assert Engine.configure == :ok
  end

  @tag engine: true
  test "start" do
    assert Engine.start == :ok
  end

  @tag engine: true
  test "stop" do
    assert Engine.stop == :ok
  end
end

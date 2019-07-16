defmodule ModelTest do
  use ExUnit.Case
  doctest Model

  test "greets the world" do
    assert Model.hello() == :world
  end
end

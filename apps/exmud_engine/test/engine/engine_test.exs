defmodule Exmud.Engine.Test.EngineTest do
  alias Exmud.Engine
  use Exmud.Engine.Test.DBTestCase
  doctest Exmud.Engine

  @tag engine: true
  test "start" do
    # {:ok, results} = Engine.start

    # assert Enum.all?(results, fn({_key, {:ok, _}}) -> true;
    #                             ({_key, {:error, :already_started}}) -> true;
    #                             (_) -> false end)
  end

  @tag engine: true
  test "stop" do
    # {:ok, results} = Engine.stop

    # assert Enum.all?(results, fn({_key, {:ok, _}}) -> true;
    #                             ({_key, {:error, :system_not_running}}) -> true;
    #                             ({_key, {:error, "StopErrorSystem"}}) -> true;
    #                             (_) -> false end)
  end
end

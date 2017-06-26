defmodule Exmud.Engine.CallbackTest do
  alias Ecto.UUID
  alias Exmud.Engine.Callback
  alias Exmud.Engine.CallbackTest.ExampleCallback, as: EC
  alias Exmud.Engine.Object
  require Logger
  use Exmud.Engine.DBTestCase

  describe "callback tests: " do
    setup [:create_new_game_object]

    @tag callback: true
    test "engine registration" do
      callback = UUID.generate()
      assert Callback.registered?(callback) == false
      assert Callback.which_module(callback) == {:error, :no_such_callback}
      assert Callback.register(callback, EC) == :ok
      assert Callback.registered?(callback) == true
      assert Callback.which_module(callback) == {:ok, EC}
      assert Callback.unregister(callback) == :ok
      assert Callback.registered?(callback) == false
    end
  end

  defp create_new_game_object(_context) do
    key = UUID.generate()
    {:ok, oid} = Object.new(key)
    %{key: key, oid: oid}
  end
end

defmodule Exmud.Engine.CallbackTest.ExampleCallback do
  @moduledoc """
  A barebones example of a callback for testing.
  """

  def run(_oid) do
    :ok
  end
end
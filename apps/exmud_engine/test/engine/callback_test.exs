defmodule Exmud.Engine.Test.CallbackTest do
  alias Ecto.UUID
  alias Exmud.Engine.Callback
  alias Exmud.Engine.Test.CallbackTest.ExampleCallback, as: EC
  alias Exmud.Engine.Object
  require Logger
  use Exmud.Engine.Test.DBTestCase, async: false

  describe "callback tests: " do
    setup [:create_new_game_object]

    @tag callback: true
    test "engine registration" do
      callback = UUID.generate()
      assert Callback.registered(callback) == {:ok, false}
      assert Callback.which_module(callback) == {:error, :no_such_callback}
      assert Callback.register(callback, EC) == {:ok, true}
      assert Callback.registered(callback) == {:ok, true}
      assert Callback.which_module(callback) == {:ok, EC}
      assert Callback.unregister(callback) == {:ok, true}
      assert Callback.registered(callback) == {:ok, false}
    end
  end

  describe "callback multi tests: " do
    setup [:create_new_object_multi]

    @tag callback: true
    @tag object: true
    test "callback lifecycle", %{multi: multi, oid: oid} = _context do
      assert Repo.transaction(Callback.has(multi, "has callback", oid, "foo")) == {:ok, %{"has callback" => false}}
      assert Repo.transaction(Callback.add(multi, "add callback", oid, "foo", "foo")) == {:ok, %{"add callback" => oid}}
      assert Repo.transaction(Callback.add(multi, "add callback", oid, "foobar", EC)) == {:ok, %{"add callback" => oid}}
      assert Repo.transaction(Callback.has(multi, "has callback", oid, "foo")) == {:ok, %{"has callback" => true}}
      assert Repo.transaction(Callback.get(multi, "get callback", oid, "foo")) == {:ok, %{"get callback" => "foo"}}
      assert Repo.transaction(Callback.get!(multi, "get callback", oid, "foo")) == {:ok, %{"get callback" => "foo"}}
      assert Repo.transaction(Callback.get(multi, "get callback", oid, "foo", "foobar")) == {:ok, %{"get callback" => "foo"}}
      assert Repo.transaction(Callback.delete(multi, "delete callback", oid, "foo")) == {:ok, %{"delete callback" => oid}}
      assert Repo.transaction(Callback.has(multi, "has callback", oid, "foo")) == {:ok, %{"has callback" => false}}
      assert Repo.transaction(Callback.run(multi, "run callback", oid, "foobar", [])) == {:ok, %{"run callback" => :ok}}
    end

    @tag callback: true
    @tag object: true
    test "callback invalid cases", %{multi: multi} = _context do
      assert Repo.transaction(Callback.has(multi, "has callback", 0, "foo")) == {:ok, %{"has callback" => false}}
      assert Repo.transaction(Callback.add(multi, "add callback", 0, "foo", "foo")) == {:error, "add callback", :no_such_object, %{}}
      assert Repo.transaction(Callback.get(multi, "get callback", 0, "foo")) == {:ok, %{"get callback" => nil}}
      assert Repo.transaction(Callback.get!(multi, "get callback", 0, "foo")) == {:error, "get callback", :no_such_callback, %{}}
      assert Repo.transaction(Callback.delete(multi, "delete callback", 0, "foo")) == {:error, "delete callback", :no_such_callback, %{}}
    end
  end

  defp create_new_game_object(_context) do
    key = UUID.generate()
    {:ok, object_id} = Object.new(key)
    %{key: key, object_id: object_id}
  end

  defp create_new_object_multi(_context) do
    key = UUID.generate()
    {:ok, results} = Ecto.Multi.new()
    |> Object.new("new_object", key)
    |> Repo.transaction()

    %{key: key, multi: Ecto.Multi.new(), oid: results["new_object"]}
  end
end

defmodule Exmud.Engine.Test.CallbackTest.ExampleCallback do
  @moduledoc """
  A barebones example of a callback for testing.
  """

  def run(_object_id, _args) do
    {:ok, :ok}
  end
end





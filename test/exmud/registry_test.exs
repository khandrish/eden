defmodule Exmud.RegistryTest do
  alias Exmud.Registry
  require Logger
  use ExUnit.Case, async: true

  describe "registry tests: " do
  
    @tag wip: true
    test "lifecycle" do
      assert Registry.key_registered?("foo") == false
      assert Registry.read_key("foo") == {:error, :no_such_key}
      assert Registry.register_key("foo", "bar") == :ok
      assert Registry.key_registered?("foo") == true
      assert Registry.read_key("foo") == {:ok, "bar"}
      assert Registry.unregister_key("foo") == :ok
      assert Registry.key_registered?("foo") == false
    end
  end
end

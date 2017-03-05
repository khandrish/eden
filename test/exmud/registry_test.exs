defmodule Exmud.RegistryTest do
  alias Exmud.Registry
  require Logger
  use ExUnit.Case, async: true

  describe "registry tests: " do

    test "lifecycle" do
      assert Registry.read_key("foo", "system") == {:error, :no_such_key}
      assert Registry.key_registered?("foo", "system") == false
      assert Registry.register_key("foo", "system", "bar") == :ok
      assert Registry.register_key("foo", "systemsystem", "bar") == :ok
      assert Registry.key_registered?("foo", "system") == true
      assert Registry.read_key("foo", "system") == {:ok, "bar"}
      assert Registry.unregister_key("foo", "system") == :ok
      assert Registry.key_registered?("foo", "system") == false
      assert Registry.key_registered?("foo", "systemsystem") == true
    end
  end
end

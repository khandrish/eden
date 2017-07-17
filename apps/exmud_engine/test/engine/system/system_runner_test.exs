defmodule Exmud.Engine.SystemRunnerTest do
  alias Exmud.Engine.System
  use Exmud.Engine.Test.DBTestCase

  describe "system runner tests:" do
    setup [:do_setup]

    @tag engine: true
    @tag system_runner: true
    test "bad systems", %{bis_key: bis_key, bss_key: bss_key, bsts_key: bsts_key} = _context do
      assert System.start(bis_key) == {:error, "foo"}
      assert System.start(bss_key) == {:error, "foo"}
      assert System.start(bsts_key) == {:ok, true}
      assert System.stop(bsts_key) == {:error, "foo"}
    end
  end

  defp do_setup(_context) do
    {:ok, true} = System.register("BadInitSystem", Exmud.Engine.SystemTest.BadInitSystem)
    {:ok, true} = System.register("BadStartSystem", Exmud.Engine.SystemTest.BadStartSystem)
    {:ok, true} = System.register("BadStopSystem", Exmud.Engine.SystemTest.BadStopSystem)

    %{bis_key: "BadInitSystem", bss_key: "BadStartSystem", bsts_key: "BadStopSystem"}
  end
end

defmodule Exmud.Engine.SystemTest.BadInitSystem do
  @moduledoc """
  A barebones example of a system for testing.
  """

  use Exmud.Engine.System

  def initialize(_args, _state) do
    {:error, "foo"}
  end
end

defmodule Exmud.Engine.SystemTest.BadStartSystem do
  @moduledoc """
  A barebones example of a system for testing.
  """

  use Exmud.Engine.System

  def start(_message, _state) do
    {:error, "foo"}
  end
end

defmodule Exmud.Engine.SystemTest.BadStopSystem do
  @moduledoc """
  A barebones example of a system for testing.
  """

  use Exmud.Engine.System

  def stop(_message, state) do
    {:error, "foo", state}
  end
end
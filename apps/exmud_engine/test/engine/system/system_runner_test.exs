defmodule Exmud.Engine.SystemRunnerTest do
  alias Exmud.Engine.System
  use Exmud.Engine.Test.DBTestCase

  describe "system runner tests:" do
    setup [:do_setup]

    @tag engine: true
    @tag system_runner: true
    test "systems", %{ses_name: ses_name, sos_name: sos_name, ies_name: ies_name, ms_name: ms_name, rs_name: rs_name,
                          rss_name: rss_name, ros_name: ros_name, rots_name: rots_name, ios_name: ios_name} = _context do

      assert System.start(rots_name) == :ok

      assert System.start(rs_name) == :ok
      assert System.start(rs_name) == {:error, :already_started}
      Process.sleep(1)
      assert System.run(rs_name) == :ok
      Process.sleep(1)
      assert System.run(rs_name) == :ok
      Process.sleep(100) # State is persisted when System is stopped. Give time for that to happen.
      assert System.start(rs_name) == :ok
      assert System.stop(rs_name) == :ok

      assert System.start(ms_name) == :ok
      assert System.call(ms_name, :error) == {:error, "MessageSystem"}
      assert System.call(ms_name, :ok) == {:ok, "MessageSystem"}
      assert System.cast(ms_name, :ok) == :ok

      assert System.start(rss_name) == :ok
      assert System.run(rss_name) == :ok

      assert System.start(ros_name) == :ok
      assert System.run(ros_name) == :ok
      assert System.stop(ros_name) == :ok

      assert System.start(ses_name, :ok) == :ok
      assert System.stop(ses_name) == {:error, "StopErrorSystem"}

      assert System.start(sos_name, :ok) == :ok
      assert System.stop(sos_name) == :ok

      assert System.start(ios_name, :ok) == :ok
      assert System.stop(ios_name) == :ok

      assert System.start(ies_name, :ok) == {:error, "InitSystem"}

      assert System.start(ros_name) == :ok
      assert System.stop(ros_name) == :ok

      assert System.start(Exmud.Engine.Test.System.ErrorStarting.name()) == {:error, :error}

      Process.sleep(100) # Give everything a change to shut down properly, otherwise errors may occur when running tests.
    end
  end

  defp do_setup(_context) do
    :ok = System.register(Exmud.Engine.SystemRunnerTest.StopErrorSystem)
    :ok = System.register(Exmud.Engine.SystemRunnerTest.StopOkSystem)
    :ok = System.register(Exmud.Engine.SystemRunnerTest.RunOkSystem)
    :ok = System.register(Exmud.Engine.SystemRunnerTest.RunStopSystem)
    :ok = System.register(Exmud.Engine.SystemRunnerTest.InitOkSystem)
    :ok = System.register(Exmud.Engine.SystemRunnerTest.InitErrorSystem)
    :ok = System.register(Exmud.Engine.SystemRunnerTest.MessageSystem)
    :ok = System.register(Exmud.Engine.SystemRunnerTest.RunOkTimeSystem)
    :ok = System.register(Exmud.Engine.SystemRunnerTest.RunSystem)
    :ok = System.register(Exmud.Engine.Test.System.ErrorStarting)

    %{ses_name: "StopErrorSystem", sos_name: "StopOkSystem", ios_name: "InitOkSystem", ies_name: "InitErrorSystem",
      rss_name: "RunStopSystem", ros_name: "RunOkSystem", ms_name: "MessageSystem", rots_name: "RunOkTimeSystem",
      rs_name: "RunSystem"
    }
  end
end

defmodule Exmud.Engine.SystemRunnerTest.InitOkSystem do
  @moduledoc """
  A barebones example of a system for testing.
  """

  use Exmud.Engine.System

  def initialize(_args) do
    {:ok, "InitSystem"}
  end

  def name, do: "InitOkSystem"
end

defmodule Exmud.Engine.SystemRunnerTest.InitErrorSystem do
  @moduledoc """
  A barebones example of a system for testing.
  """

  use Exmud.Engine.System

  def initialize(_args) do
    {:error, "InitSystem"}
  end

  def name, do: "InitErrorSystem"
end

defmodule Exmud.Engine.SystemRunnerTest.StopErrorSystem do
  @moduledoc """
  A barebones example of a system for testing.
  """

  use Exmud.Engine.System

  def name, do: "StopErrorSystem"

  def stop(_message, state) do
    {:error, "StopErrorSystem", state}
  end
end

defmodule Exmud.Engine.SystemRunnerTest.StopOkSystem do
  @moduledoc """
  A barebones example of a system for testing.
  """

  use Exmud.Engine.System

  def name, do: "StopOkSystem"

  def stop(_message, state) do
    {:ok, state}
  end
end

defmodule Exmud.Engine.SystemRunnerTest.RunErrorSystem do
  @moduledoc """
  A barebones example of a system for testing.
  """

  use Exmud.Engine.System

  def initialize(_args) do
    {:ok, 0}
  end

  def name, do: "RunErrorSystem"

  def run(state) do
    {:error, "RunErrorSystem", state}
  end
end

defmodule Exmud.Engine.SystemRunnerTest.RunStopSystem do
  @moduledoc """
  A barebones example of a system for testing.
  """

  use Exmud.Engine.System

  def name, do: "RunStopSystem"

  def run(state) do
    {:stop, "RunStopSystem", state}
  end
end

defmodule Exmud.Engine.SystemRunnerTest.RunOkSystem do
  @moduledoc """
  A barebones example of a system for testing.
  """

  use Exmud.Engine.System

  def name, do: "RunOkSystem"

  def run(state) do
    {:ok, state}
  end
end

defmodule Exmud.Engine.SystemRunnerTest.RunOkTimeSystem do
  @moduledoc """
  A barebones example of a system for testing.
  """

  use Exmud.Engine.System

  def initialize(_args) do
    {:ok, 1}
  end

  def name, do: "RunOkTimeSystem"

  def run(state) when state < 2 do
    {:ok, state + 1, 1}
  end

  def run(state) do
    {:stop, "RunOkTimeSystem", state}
  end
end

defmodule Exmud.Engine.SystemRunnerTest.MessageSystem do
  @moduledoc """
  A barebones example of a system for testing.
  """

  use Exmud.Engine.System

  def handle_message(:error, state) do
    {:error, "MessageSystem", state}
  end

  def handle_message(:ok, state) do
    {:ok, "MessageSystem", state}
  end

  def name, do: "MessageSystem"
end

defmodule Exmud.Engine.SystemRunnerTest.RunSystem do
  @moduledoc """
  A barebones example of a system for testing.

  Start
  Run 2x
  Start
  Stop
  """

  use Exmud.Engine.System

  def name, do: "RunSystem"

  def start(:error, _state) do
    {:error, :ok}
  end

  def start(_args, 4) do
    {:ok, 0}
  end

  def start(_args, _state) do # First start
    {:ok, nil, 0}
  end

  def run(nil) do # Immediately after first start
    {:ok, 0, 0}
  end

  def run(0) do
    {:ok, 1}
  end

  def run(1) do # Call run to trigger
    {:error, :ok, 2}
  end

  def run(2) do # Call run again to trigger
    {:error, :ok, 3, 0}
  end

  def run(3) do
    {:stop, :ok, 4}
  end

  def stop(_, 4) do
    {:error, :ok, 5}
  end

  def stop(_, state) do
    {:ok, state}
  end
end
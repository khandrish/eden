defmodule Exmud.Engine.SystemRunnerTest do
  alias Exmud.Engine.System
  use Exmud.Engine.Test.DBTestCase

  describe "system runner tests:" do
    setup [:do_setup]

    @tag engine: true
    @tag system_runner: true
    test "systems", %{ses_key: ses_key, sos_key: sos_key, ies_key: ies_key, ms_key: ms_key, rs_key: rs_key,
                          rss_key: rss_key, ros_key: ros_key, rots_key: rots_key, ios_key: ios_key} = _context do

      assert System.start(rots_key) == {:ok, :started}

      assert System.start(rs_key) == {:ok, :started}
      assert System.run(rs_key) == {:error, :already_running}
      Process.sleep(1)
      assert System.run(rs_key) == {:ok, :running}
      Process.sleep(1)
      assert System.run(rs_key) == {:ok, :running}
      Process.sleep(100) # State is persisted when System is stopped. Give time for that to happen.
      assert System.start(rs_key) == {:ok, :started}
      assert System.stop(rs_key) == {:ok, :stopped}

      assert System.start(ms_key) == {:ok, :started}
      assert System.call(ms_key, :error) == {:error, "MessageSystem"}
      assert System.call(ms_key, :ok) == {:ok, "MessageSystem"}
      assert System.cast(ms_key, :ok) == {:ok, true}

      assert System.start(rss_key) == {:ok, :started}
      assert System.run(rss_key) == {:ok, :running}

      assert System.start(ros_key) == {:ok, :started}
      assert System.run(ros_key) == {:ok, :running}
      assert System.stop(ros_key) == {:ok, :stopped}

      assert System.start(ses_key, :ok) == {:ok, :started}
      assert System.stop(ses_key) == {:error, "StopErrorSystem"}

      assert System.start(sos_key, :ok) == {:ok, :started}
      assert System.stop(sos_key) == {:ok, :stopped}

      assert System.start(ios_key, :ok) == {:ok, :started}
      assert System.stop(ios_key) == {:ok, :stopped}

      assert System.start(ies_key, :ok) == {:error, "InitSystem"}

      assert System.start(ros_key) == {:ok, :started}
      assert System.stop(ros_key) == {:ok, :stopped}

      Process.sleep(100) # Give everything a change to shut down properly, otherwise errors may occur when running tests.
    end
  end

  defp do_setup(_context) do
    {:ok, true} = System.register(Exmud.Engine.SystemRunnerTest.StopErrorSystem)
    {:ok, true} = System.register(Exmud.Engine.SystemRunnerTest.StopOkSystem)
    {:ok, true} = System.register(Exmud.Engine.SystemRunnerTest.RunOkSystem)
    {:ok, true} = System.register(Exmud.Engine.SystemRunnerTest.RunStopSystem)
    {:ok, true} = System.register(Exmud.Engine.SystemRunnerTest.InitOkSystem)
    {:ok, true} = System.register(Exmud.Engine.SystemRunnerTest.InitErrorSystem)
    {:ok, true} = System.register(Exmud.Engine.SystemRunnerTest.MessageSystem)
    {:ok, true} = System.register(Exmud.Engine.SystemRunnerTest.RunOkTimeSystem)
    {:ok, true} = System.register(Exmud.Engine.SystemRunnerTest.RunSystem)

    %{ses_key: "StopErrorSystem", sos_key: "StopOkSystem", ios_key: "InitOkSystem", ies_key: "InitErrorSystem",
      rss_key: "RunStopSystem", ros_key: "RunOkSystem", ms_key: "MessageSystem", rots_key: "RunOkTimeSystem",
      rs_key: "RunSystem"
    }
  end
end

defmodule Exmud.Engine.SystemRunnerTest.InitOkSystem do
  @moduledoc """
  A barebones example of a system for testing.
  """

  use Exmud.Engine.Test.System

  def initialize(_args) do
    {:ok, "InitSystem"}
  end

  def name, do: "InitOkSystem"
end

defmodule Exmud.Engine.SystemRunnerTest.InitErrorSystem do
  @moduledoc """
  A barebones example of a system for testing.
  """

  use Exmud.Engine.Test.System

  def initialize(_args) do
    {:error, "InitSystem"}
  end

  def name, do: "InitErrorSystem"
end

defmodule Exmud.Engine.SystemRunnerTest.StopErrorSystem do
  @moduledoc """
  A barebones example of a system for testing.
  """

  use Exmud.Engine.Test.System

  def name, do: "StopErrorSystem"

  def stop(_message, state) do
    {:error, "StopErrorSystem", state}
  end
end

defmodule Exmud.Engine.SystemRunnerTest.StopOkSystem do
  @moduledoc """
  A barebones example of a system for testing.
  """

  use Exmud.Engine.Test.System

  def name, do: "StopOkSystem"

  def stop(_message, state) do
    {:ok, state}
  end
end

defmodule Exmud.Engine.SystemRunnerTest.RunErrorSystem do
  @moduledoc """
  A barebones example of a system for testing.
  """

  use Exmud.Engine.Test.System

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

  use Exmud.Engine.Test.System

  def name, do: "RunStopSystem"

  def run(state) do
    {:stop, "RunStopSystem", state}
  end
end

defmodule Exmud.Engine.SystemRunnerTest.RunOkSystem do
  @moduledoc """
  A barebones example of a system for testing.
  """

  use Exmud.Engine.Test.System

  def name, do: "RunOkSystem"

  def run(state) do
    {:ok, state}
  end
end

defmodule Exmud.Engine.SystemRunnerTest.RunOkTimeSystem do
  @moduledoc """
  A barebones example of a system for testing.
  """

  use Exmud.Engine.Test.System

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

  use Exmud.Engine.Test.System

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

  use Exmud.Engine.Test.System

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
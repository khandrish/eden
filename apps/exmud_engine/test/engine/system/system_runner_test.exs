defmodule Exmud.Engine.SystemRunnerTest do
  alias Exmud.Engine.System
  use Exmud.Engine.Test.DBTestCase

  describe "system runner tests:" do
    setup [:do_setup]

    @tag engine: true
    @tag system_runner: true
    test "bad systems", %{ses_key: ses_key, sos_key: sos_key, is_key: is_key, ms_key: ms_key,
                          rss_key: rss_key, ros_key: ros_key, res_key: res_key, rots_key: rots_key} = _context do

      assert System.start(rots_key) == {:ok, true}

      assert System.start(rss_key) == {:ok, true}
      assert System.run(rss_key) == {:ok, "RunStopSystem"}

      assert System.start(ros_key) == {:ok, true}
      assert System.run(ros_key) == {:ok, "RunOkSystem"}
      assert System.stop(ros_key) == {:ok, nil}

      assert System.start(res_key) == {:ok, true}
      assert System.run(res_key) == {:error, "RunErrorSystem"}
      assert System.stop(res_key) == {:ok, nil}


      assert System.start(ses_key, :ok) == {:ok, true}
      assert System.stop(ses_key) == {:error, "StopErrorSystem"}

      assert System.start(sos_key, :ok) == {:ok, true}
      assert System.stop(sos_key) == {:ok, "StopOkSystem"}


      assert System.start(is_key, :ok) == {:ok, true}
      assert System.stop(is_key) == {:ok, "InitSystem"}
      assert System.start(is_key, :error) == {:error, "InitSystem"}
      assert System.start(is_key, :time) == {:ok, true}
      assert System.stop(is_key) == {:ok, "InitSystem"}


      assert System.start(ms_key) == {:ok, true}
      assert System.call(ms_key, :error) == {:error, "MessageSystem"}
      assert System.call(ms_key, :ok) == {:ok, "MessageSystem"}
      assert System.call(ms_key, :time) == {:ok, "MessageSystem"}
      assert System.cast(ms_key, :ok) == {:ok, true}
      assert System.call(ms_key, :stop) == {:ok, "MessageSystem"}
    end
  end

  defp do_setup(_context) do
    {:ok, true} = System.register("StopErrorSystem", Exmud.Engine.SystemTest.StopErrorSystem)
    {:ok, true} = System.register("StopOkSystem", Exmud.Engine.SystemTest.StopOkSystem)
    {:ok, true} = System.register("RunErrorSystem", Exmud.Engine.SystemTest.RunErrorSystem)
    {:ok, true} = System.register("RunOkSystem", Exmud.Engine.SystemTest.RunOkSystem)
    {:ok, true} = System.register("RunStopSystem", Exmud.Engine.SystemTest.RunStopSystem)
    {:ok, true} = System.register("InitSystem", Exmud.Engine.SystemTest.InitSystem)
    {:ok, true} = System.register("MessageSystem", Exmud.Engine.SystemTest.MessageSystem)
    {:ok, true} = System.register("RunOkTimeSystem", Exmud.Engine.SystemTest.RunOkTimeSystem)

    %{ses_key: "StopErrorSystem", sos_key: "StopOkSystem", is_key: "InitSystem", rss_key: "RunStopSystem",
      ros_key: "RunOkSystem", res_key: "RunErrorSystem", ms_key: "MessageSystem", rots_key: "RunOkTimeSystem"
    }
  end
end

defmodule Exmud.Engine.SystemTest.InitSystem do
  @moduledoc """
  A barebones example of a system for testing.
  """

  use Exmud.Engine.System

  def initialize(:error, _state) do
    {:error, "InitSystem"}
  end

  def initialize(:ok, _state) do
    {:ok, "InitSystem"}
  end

  def initialize(:time, _state) do
    {:ok, "InitSystem", 100}
  end
end

defmodule Exmud.Engine.SystemTest.StopErrorSystem do
  @moduledoc """
  A barebones example of a system for testing.
  """

  use Exmud.Engine.System

  def stop(_message, state) do
    {:error, "StopErrorSystem", state}
  end
end

defmodule Exmud.Engine.SystemTest.StopOkSystem do
  @moduledoc """
  A barebones example of a system for testing.
  """

  use Exmud.Engine.System

  def stop(_message, state) do
    {:ok, "StopOkSystem", state}
  end
end

defmodule Exmud.Engine.SystemTest.RunErrorSystem do
  @moduledoc """
  A barebones example of a system for testing.
  """

  use Exmud.Engine.System

  def run(state) do
    {:error, "RunErrorSystem", state}
  end
end

defmodule Exmud.Engine.SystemTest.RunStopSystem do
  @moduledoc """
  A barebones example of a system for testing.
  """

  use Exmud.Engine.System

  def run(state) do
    {:stop, "RunStopSystem", state}
  end
end

defmodule Exmud.Engine.SystemTest.RunOkSystem do
  @moduledoc """
  A barebones example of a system for testing.
  """

  use Exmud.Engine.System

  def run(state) do
    {:ok, "RunOkSystem", state}
  end
end

defmodule Exmud.Engine.SystemTest.RunOkTimeSystem do
  @moduledoc """
  A barebones example of a system for testing.
  """

  use Exmud.Engine.System

  def initialize(_args, _state) do
    {:ok, 0, 1}
  end

  def run(state) when state < 2 do
    {:ok, "RunOkTimeSystem", state + 1, 1}
  end

  def run(state) do
    {:stop, "RunOkTimeSystem", state}
  end
end

defmodule Exmud.Engine.SystemTest.MessageSystem do
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

  def handle_message(:stop, state) do
    {:stop, "MessageSystem", state}
  end

  def handle_message(:time, state) do
    {:ok, "MessageSystem", state, 100}
  end
end
defmodule Exmud.PlayerSessionTest do
  alias Ecto.UUID
  alias Exmud.Object
  alias Exmud.Player
  alias Exmud.PlayerSession
  require Logger
  use ExUnit.Case, async: true

  doctest Exmud.PlayerSession

  describe "player session tests: " do
    setup [:add_player]

    @tag player_session: true
    test "session lifecycle", %{key: key} = _context do
      assert PlayerSession.active(key) == {:ok, false}
      assert PlayerSession.stop(key) == {:error, :no_session_active}
      assert PlayerSession.start(key) == {:ok, :success}
      assert PlayerSession.active(key) == {:ok, true}
      assert PlayerSession.process_command_string(key, "move north") == {:ok, :success}
      assert PlayerSession.process_command_string(key, "move north") == {:ok, :success}
      me = self()
      assert PlayerSession.send_message(key, :bar) == {:ok, :success}
      assert PlayerSession.stream_output(key, fn(message) -> send(me, {:message, message}) end) == {:ok, :success}
      assert PlayerSession.send_message(key, :foo) == {:ok, :success}
      assert rec() == :bar
      assert rec() == :foo
      assert PlayerSession.stop(key) == {:ok, :success}
      Process.sleep(1) # Give session time to stop and be dereferenced
      assert PlayerSession.active(key) == {:ok, false}
    end
  end

  defp rec() do
    receive do
      {:message, message} -> message
      after 500 -> :error
    end
  end

  defp add_player(_context) do
    key = UUID.generate()
    {:ok, oid} = Player.add(key)
    {:ok, oid} = Object.add_command_set(oid, Exmud.PlayerSessionTest.ExampleCommandSet)
    %{key: key, oid: oid}
  end
end

defmodule Exmud.PlayerSessionTest.ExampleCommandSet do
  alias Exmud.CommandSetTemplate
  @behaviour Exmud.CommandSetTemplate

  def init(command_set_template) do
    command_set_template
    |> CommandSetTemplate.add_command(Exmud.PlayerSessionTest.ExampleCommand)
  end
end

defmodule Exmud.PlayerSessionTest.ExampleCommand do
  @moduledoc """
  A barebones example of a command template instance for testing.
  """

  alias Exmud.CommandTemplate
  @behaviour Exmud.Command

  def init(command_template) do
    command_template
    |> CommandTemplate.set_key("move")
    |> CommandTemplate.add_alias("go")
    |> CommandTemplate.add_alias("run")
    |> CommandTemplate.add_alias("walk")
  end
end
defmodule Exmud.CommandProcessorTest do
  alias Ecto.UUID
  alias Exmud.CommandProcessor
  alias Exmud.CommandSetTemplate
  alias Exmud.Object
  require Logger
  use ExUnit.Case

  describe "command processor tests: " do
    setup [:create_new_object]

  #   @tag command_processor: true
  #   test "command processor lifecycle", %{key: key, oid: oid} = _context do
  #     Object.add_command_set(oid, Exmud.CommandProcessorTest.ExampleCommandSet1)

  #     command_string = "move north"
  #     {:ok, results} = CommandProcessor.process(command_string, oid)
  #   end

  #   @tag command_processor: true
  #   test "objects have callbacks", %{key: key, oid: oid} = _context do
  #     Object.add_command_set(oid, Exmud.CommandProcessorTest.ExampleCommandSet1)
  #     Object.add_callback(oid, "__command_context", Exmud.Command.Context.Default)
  #     Object.add_callback(oid, "__command_string_preprocessors", [Exmud.Command.Preproccessor.Trim])
  #     Object.add_callback(oid, "__command_string_validators", [])

  #     command_string = "move north"
  #     {:ok, results} = CommandProcessor.process(command_string, oid)
  #   end

  #   @tag command_processor: true
  #   test "objects don't have callbacks", %{key: key, oid: oid} = _context do
  #     Object.add_command_set(oid, Exmud.CommandProcessorTest.ExampleCommandSet1)

  #     command_string = "move north"
  #     {:ok, results} = CommandProcessor.process(command_string, oid)
  #   end

  #   @tag command_processor: true
  #   test "extract command", %{key: key, oid: oid} = _context do
  #     Object.add_command_set(oid, Exmud.CommandProcessorTest.ExampleCommandSet1)

  #     command_string = "badcommand"
  #     {:ok, results} = CommandProcessor.process(command_string, oid)
  #   end

  #   @tag command_processor: true
  #   test "multiple commands matched", %{key: key, oid: oid} = _context do
  #     Object.add_command_set(oid, Exmud.CommandProcessorTest.ExampleCommandSetDupe)

  #     command_string = "move north"
  #     {:ok, results} = CommandProcessor.process(command_string, oid)
  #   end

  #   @tag command_processor: true
  #   test "execute command error", %{key: key, oid: oid} = _context do
  #     Object.add_command_set(oid, Exmud.CommandProcessorTest.ExampleCommandSetError)

  #     command_string = "move north"
  #     {:error, {:execute_command, :bad_command}} = CommandProcessor.process(command_string, oid)
  #   end
  end

  defp create_new_object(_context) do
    key = UUID.generate()
    {:ok, oid} = Object.new(key)
    %{key: key, oid: oid}
  end
end

defmodule Exmud.CommandProcessorTest.ExampleCommandSet1 do
  alias Exmud.CommandSetTemplate

  def init(command_set_template) do
    command_set_template
    |> CommandSetTemplate.add_command(Exmud.CommandProcessorTest.ExampleCommand1)
    |> CommandSetTemplate.add_command(Exmud.CommandProcessorTest.ExampleCommand2)
    |> CommandSetTemplate.add_command(Exmud.CommandProcessorTest.ExampleCommand3)
  end
end

defmodule Exmud.CommandProcessorTest.ExampleCommandSetDupe do
  alias Exmud.CommandSetTemplate

  def init(command_set_template) do
    command_set_template
    |> CommandSetTemplate.add_command(Exmud.CommandProcessorTest.ExampleCommand1)
    |> CommandSetTemplate.add_command(Exmud.CommandProcessorTest.ExampleCommand4)
  end
end

defmodule Exmud.CommandProcessorTest.ExampleCommandSet2 do
  alias Exmud.CommandSetTemplate

  def init(command_set_template) do
    command_set_template
    |> CommandSetTemplate.add_command(Exmud.CommandProcessorTest.ExampleCommand2)
    |> CommandSetTemplate.add_command(Exmud.CommandProcessorTest.ExampleCommand3)
    |> CommandSetTemplate.add_command(Exmud.CommandProcessorTest.ExampleCommand4)
  end
end

defmodule Exmud.CommandProcessorTest.ExampleCommandSet3 do
  alias Exmud.CommandSetTemplate

  def init(command_set_template) do
    command_set_template
    |> CommandSetTemplate.add_command(Exmud.CommandProcessorTest.ExampleCommand3)
    |> CommandSetTemplate.add_command(Exmud.CommandProcessorTest.ExampleCommand4)
  end
end

defmodule Exmud.CommandProcessorTest.ExampleCommandSet4 do
  alias Exmud.CommandSetTemplate

  def init(command_set_template) do
    command_set_template
    |> CommandSetTemplate.add_command(Exmud.CommandProcessorTest.ExampleCommand4)
  end
end

defmodule Exmud.CommandProcessorTest.ExampleCommandSetError do
  alias Exmud.CommandSetTemplate

  def init(command_set_template) do
    command_set_template
    |> CommandSetTemplate.add_command(Exmud.CommandProcessorTest.ExampleCommandError)
  end
end

defmodule Exmud.CommandProcessorTest.ExampleCommand1 do
  @moduledoc """
  A barebones example of a command template instance for testing.
  """

  alias Exmud.CommandTemplate
  require Logger
  @behaviour Exmud.Command

  def init(command_template) do
    command_template
    |> CommandTemplate.set_key("move")
    |> CommandTemplate.add_alias("go")
    |> CommandTemplate.add_alias("run")
    |> CommandTemplate.add_alias("walk")
  end

  def run(command) do
    Logger.debug("Command executing: #{inspect(command)}")
    {:ok, nil}
  end

  def parse(string) do
    Logger.debug("Command parsing: #{inspect(string)}")

    {:ok, %{destination: string}}
  end
end

defmodule Exmud.CommandProcessorTest.ExampleCommand2 do
  @moduledoc """
  A barebones example of a command template instance for testing.
  """

  alias Exmud.CommandTemplate
  @behaviour Exmud.Command

  def init(command_template) do
    command_template
    |> CommandTemplate.set_key("look")
    |> CommandTemplate.add_alias("gaze")
    |> CommandTemplate.add_alias("examine")
    |> CommandTemplate.add_alias("peer")
  end

  def run(_), do: {:ok, nil}
  def parse(_), do: {:ok, nil}
end

defmodule Exmud.CommandProcessorTest.ExampleCommand3 do
  @moduledoc """
  A barebones example of a command template instance for testing.
  """

  alias Exmud.CommandTemplate
  @behaviour Exmud.Command

  def init(command_template) do
    command_template
    |> CommandTemplate.set_key("say")
    |> CommandTemplate.add_alias("speak")
  end

  def run(_), do: {:ok, nil}
  def parse(_), do: {:ok, nil}
end

defmodule Exmud.CommandProcessorTest.ExampleCommand4 do
  @moduledoc """
  A barebones example of a command template instance for testing.
  """

  alias Exmud.CommandTemplate
  @behaviour Exmud.Command

  def init(command_template) do
    command_template
    |> CommandTemplate.set_key("move")
  end

  def run(_), do: {:ok, nil}
  def parse(_), do: {:ok, nil}
end

defmodule Exmud.CommandProcessorTest.ExampleCommandError do
  @moduledoc """
  A barebones example of a command template instance for testing.
  """

  alias Exmud.CommandTemplate
  @behaviour Exmud.Command

  def init(command_template) do
    command_template
    |> CommandTemplate.set_key("move")
  end

  def run(_), do: {:error, :bad_command}
  def parse(_), do: {:ok, nil}
end
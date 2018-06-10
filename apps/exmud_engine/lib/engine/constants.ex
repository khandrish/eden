defmodule Exmud.Engine.Constants do
  defmacro command_execution_success do
    quote do: "success"
  end

  defmacro command_execution_failure do
    quote do: "failure"
  end
end

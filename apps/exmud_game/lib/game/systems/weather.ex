defmodule Exmud.Game.System.Weather do
  use Exmud.Game.System

    @doc false
    def initialize(_args), do: {:ok, %{}}

    @doc false
    def run(state), do: {:ok, state}

    @doc false
    def start(_args, state), do: {:ok, state}

    @doc false
    def stop(_args, state), do: {:ok, state}
end
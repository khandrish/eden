defmodule Exmud.Game.System.Time do
  use Exmud.Game.System

    @doc false
    def handle_message("epoch", state), do: {:ok, DateTime.to_unix(DateTime.utc_now()), state}

    @doc false
    def initialize(_args), do: {:ok, %{}}

    @doc false
    def run(state), do: {:ok, state}

    @doc false
    def start(_args, state), do: {:ok, state}

    @doc false
    def stop(_args, state), do: {:ok, state}
end
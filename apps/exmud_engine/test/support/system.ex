defmodule Exmud.Engine.Test.System do

  @doc false
  defmacro __using__(_) do
    quote location: :keep do

      @doc false
      def handle_message(message, state), do: {:ok, message, state}

      @doc false
      def initialize(_args), do: {:ok, nil}

      @doc false
      def run(state), do: {:ok, state}

      @doc false
      def start(_args, state), do: {:ok, state}

      @doc false
      def stop(_args, state), do: {:ok, state}

      defoverridable [handle_message: 2,
                      initialize: 1,
                      run: 1,
                      start: 2,
                      stop: 2]
    end
  end
end
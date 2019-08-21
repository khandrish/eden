defmodule ExmudWeb.DatatableSimulationProvider do
  @behaviour ExmudWeb.DatatableLiveProvider

  @impl ExmudWeb.DatatableLiveProvider
  def load(state) do
    IO.inspect(state)
    data = for _ <- 1..10, do: %{foo: "bar", bar: "foo", foobar: "barfoo", barfoo: "foobar"}
    {:ok, data}
  end
end

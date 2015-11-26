defmodule Eden.TestHelper do
  use ExUnit.CaseTemplate

  using do
    quote do
      alias Eden.Repo
      use Plug.Test

      # Remember to change this from `defp` to `def` or it can't be used in your
      # tests.
      def send_request(conn) do
        conn
        |> put_private(:plug_skip_csrf_protection, true)
        |> Eden.Endpoint.call([])
      end
    end
  end
end

ExUnit.start

Mix.Task.run "ecto.create", ["--quiet"]
Mix.Task.run "ecto.migrate", ["--quiet"]
Ecto.Adapters.SQL.begin_test_transaction(Eden.Repo)


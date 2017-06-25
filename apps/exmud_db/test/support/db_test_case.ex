defmodule Exmud.DB.DBTestCase do
  @moduledoc """
  This module defines the test case to be used by tests.

  This should be used by tests which interact with the
  database.

  Finally, if the test case interacts with the database,
  it cannot be async. For this reason, every test runs
  inside a transaction which is reset at the beginning
  of the test unless the test case is marked as async.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      alias Exmud.DB.Repo
    end
  end

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Exmud.DB.Repo)

    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(Exmud.DB.Repo, {:shared, self()})
    end

    :ok
  end
end

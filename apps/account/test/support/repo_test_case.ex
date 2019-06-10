defmodule Exmud.Account.RepoTestCase do
  @moduledoc """
  This module defines the test case to be used by tests which interact with the database.

  Since the test case interacts with the database, it cannot be async. For this reason, every test runs inside a
  transaction which is reset at the beginning of the test unless the test case is marked as async.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      alias Exmud.Account.Repo
      use ExUnit.Case, async: false

      setup do
        :ok = Ecto.Adapters.SQL.Sandbox.checkout(Exmud.Account.Repo)

        Ecto.Adapters.SQL.Sandbox.mode(Exmud.Account.Repo, {:shared, self()})

        :ok
      end
    end
  end
end

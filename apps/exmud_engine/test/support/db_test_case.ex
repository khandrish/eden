defmodule Exmud.Engine.Test.DBTestCase do
  @moduledoc """
  This module defines the test case to be used by tests which interact with the database.

  Since the test case interacts with the database, it cannot be async. For this reason, every test runs inside a
  transaction which is reset at the beginning of the test unless the test case is marked as async.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      alias Ecto.Multi
      alias Exmud.Engine.Repo
      use ExUnit.Case, async: false
    end
  end

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Exmud.Engine.Repo)

    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(Exmud.Engine.Repo, {:shared, self()})
    end

    :ok
  end
end

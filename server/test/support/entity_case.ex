defmodule Eden.EntityCase do
  @moduledoc """
  This module defines the test case to be used by
  model tests.

  You may define functions here to be used as helpers in
  your model tests. See `errors_on/2`'s definition as reference.

  Finally, if the test case interacts with the database,
  it cannot be async. For this reason, every test runs
  inside a transaction which is reset at the beginning
  of the test unless the test case is marked as async.
  """

  use ExUnit.CaseTemplate
  alias Eden.Repo
  alias Eden.EntityManager

  using do
    quote do
      alias Eden.Entity
      alias Eden.EntityManager, as: EM
      import Eden.EntityCase
      use Eden.ModelCase
    end
  end

  @doc """
  Helper for creating a Entity model and saving it to the database for use in
  test cases. Is not automatically cleaned up.
  """
  def create_entity(components \\ %{}) do
    EntityManager.create_entity
  end
end
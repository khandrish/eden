defmodule Eden.PlayerCase do
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
  alias Eden.Player

  using do
    quote do
      alias Eden.Player
      import Eden.PlayerCase
      use Eden.ModelCase
    end
  end

  @doc """
  Helper for creating a Player model and saving it to the database for use in
  test cases. Is not automatically cleaned up.
  """
  def create_player() do
    params = %{
      :login => Ecto.UUID.generate,
      :password => Ecto.UUID.generate,
      :email => "#{Ecto.UUID.generate}@eden.com",
      :name => Ecto.UUID.generate
    }
    Player.new(params)
    |> Player.insert
  end
end
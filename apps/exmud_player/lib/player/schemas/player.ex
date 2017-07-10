defmodule Exmud.Engine.Schema.Player do
  use Exmud.Common.Schema

  schema "player" do
    field :email, :string
    field :email_verified, :boolean
    field :login, :string
    field :password, :string
    field :nickname, :string
    field :failed_login_attempts, :integer
    field :last_login, :utc_datetime
    field :last_nickname_change, :utc_datetime
  end

  def changeset(player, params \\ %{}) do
    player
    |> cast(params, [:email,
                     :email_verified,
                     :login,
                     :password,
                     :nickname,
                     :failed_login_attempts,
                     :last_login,
                     :last_nickname_change])
  end
end
defmodule Eden.Schema.Player do
  use Eden.Web, :changeset

  schema "players" do
    field :login, :string
    field :last_login, Calecto.DateTimeUTC
    field :failed_login_attempts, :integer, default: 0
    has_many :player_locks, Eden.PlayerLock
    has_many :player_tokens, Eden.PlayerToken

    field :email, :string
    field :email_verified, :boolean, default: false
    
    field :hash, :string

    field :name, :string
    field :last_name_change, Calecto.DateTimeUTC

    field :password, :string, virtual: true

    timestamps
  end
end
defmodule Eden.Schema.Player do
  use Eden.Web, :schema

  schema "players" do
    has_many :player_locks, Eden.Schema.PlayerLock
    has_many :player_tokens, Eden.Schema.PlayerToken

    field :login, :string
    field :last_login, Calecto.DateTimeUTC
    field :failed_login_attempts, :integer, default: 0

    field :email, :string
    field :email_verified, :boolean, default: false
    
    field :hash, :string

    field :name, :string

    field :password, :string, virtual: true

    timestamps
  end
end
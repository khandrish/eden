defmodule Eden.Schema.PlayerLock do
  use Eden.Web, :schema

  schema "player_locks" do
    belongs_to :player, Eden.Schema.Player

    field :type, :string
    field :reason, :string
    field :expiry, Calecto.DateTimeUTC

    timestamps
  end
end

defmodule Eden.Schema.PlayerToken do
  use Eden.Web, :schema

  schema "player_tokens" do
    belongs_to :player, Eden.Player

    field :type, :string
    field :token, :string

    timestamps
  end
end

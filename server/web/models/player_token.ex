defmodule Eden.PlayerToken do
  use Eden.Web, :model

  schema "player_tokens" do
    belongs_to :player, Eden.Player

    field :type, :string
    field :token, :binary_id
    field :expiry, :string

    timestamps
  end

  def new(params) do
    result = %Eden.PlayerToken{}
    |> cast(params, ~w(player_id type expiry), [])
  end
end

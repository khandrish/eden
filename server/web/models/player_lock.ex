defmodule Eden.PlayerLock do
  use Eden.Web, :model

  schema "player_locks" do
    belongs_to :player, Eden.Player

    field :type, :string
    field :reason, :string
    field :duration, :string
    field :created_by, :binary_id
    field :last_modified_by, :binary_id

    timestamps
  end

  def changeset(:create, model, params) do
    model
    |> cast(params, ~w(player_id type reason duration created_by last_modified_by), [])
  end

  def changeset(:update, model, params) do
    model
    |> cast(params, ~w(last_modified_by), ~w(duration reason type))
  end
end

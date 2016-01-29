defmodule Eden.PlayerLock do
  use Eden.Web, :model

  schema "player_locks" do
    belongs_to :player, Eden.Player

    field :type, :string
    field :reason, :string
    field :duration, :string
    field :created_by, :integer
    field :last_modified_by, :integer

    timestamps
  end

  @create_required_fields ~w(player_id type reason duration created_by last_modified_by)
  def changeset(:create, model, params) do
    model
    |> cast(params, @create_required_fields)
  end

  @update_required_fields ~w(last_modified_by)
  @update_optional_fields ~w(duration reason type)
  def changeset(:update, model, params) do
    model
    |> cast(params, @update_required_fields, @update_optional_fields)
  end
end

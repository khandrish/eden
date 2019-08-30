defmodule Exmud.Engine.MudCallback do
  use Ecto.Schema
  import Ecto.Changeset

  @timestamps_opts [type: :utc_datetime_usec]

  schema "mud_callbacks" do
    field :config, :map
    belongs_to :mud, Exmud.Engine.Mud
    belongs_to :callback, Exmud.Builder.Callback

    timestamps()
  end

  @doc false
  def changeset(mud_callback, attrs) do
    mud_callback
    |> cast(attrs, [:config, :description, :mud_id, :callback_id])
    |> validate_required([:config])
    |> foreign_key_constraint(:mud_id)
    |> foreign_key_constraint(:callback_id)
    |> unique_constraint(:mud_id, name: "mud_callback_index")
  end
end

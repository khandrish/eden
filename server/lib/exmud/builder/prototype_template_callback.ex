defmodule Exmud.Builder.PrototypeTemplateCallback do
  use Ecto.Schema
  import Ecto.Changeset

  @timestamps_opts [type: :utc_datetime_usec]
  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "prototype_template_callbacks" do
    field :config, :map
    belongs_to :prototype_template, Exmud.Builder.PrototypeTemplate

    timestamps()
  end

  @doc false
  def changeset(prototype_template_callback, attrs) do
    prototype_template_callback
    |> cast(attrs, [:config])
    |> validate_required([:config])
  end
end

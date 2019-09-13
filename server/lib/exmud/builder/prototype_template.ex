defmodule Exmud.Builder.PrototypeTemplate do
  use Ecto.Schema
  import Ecto.Changeset

  @timestamps_opts [type: :utc_datetime_usec]
  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "prototype_templates" do
    belongs_to :template, Exmud.Builder.Template
    belongs_to :prototype, Exmud.Builder.Prototype
    has_many :callbacks, Exmud.Builder.PrototypeTemplateCallback

    timestamps()
  end

  @doc false
  def changeset(prototype_template, attrs) do
    prototype_template
    |> cast(attrs, [])
    |> validate_required([])
  end
end

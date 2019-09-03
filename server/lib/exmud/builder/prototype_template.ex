defmodule Exmud.Builder.PrototypeTemplate do
  use Ecto.Schema
  import Ecto.Changeset

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

defmodule Exmud.Prototype.PrototypeTemplate do
  use Ecto.Schema
  import Ecto.Changeset

  schema "prototype_templates" do
    belongs_to :template, Exmud.Template.Template
    belongs_to :prototype, Exmud.Prototype.Prototype
    has_many :prototype_template_callbacks, Exmud.Prototype.PrototypeTemplateCallback
    has_many :callbacks, through: [:prototype_template_callbacks, :callback]

    timestamps()
  end

  @doc false
  def changeset(prototype_template, attrs) do
    prototype_template
    |> cast(attrs, [:prototype_id, :template_id])
    |> validate_required([:prototype_id, :template_id])
  end
end

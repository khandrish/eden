defmodule Exmud.Template.Template do
  use Ecto.Schema
  import Ecto.Changeset

  schema "templates" do
    field :name, :string
    belongs_to :template_category, Exmud.Template.TemplateCategory
    belongs_to :template_type, Exmud.Template.TemplateType
    belongs_to :mud, Exmud.Engine.Mud
    has_many :callbacks, Exmud.Template.TemplateCallback
    has_many :decorators, Exmud.Template.TemplateDecorator

    timestamps()
  end

  @doc false
  def changeset(template, attrs) do
    template
    |> cast(attrs, [:name, :mud_id])
    |> validate_required([:name])
    |> unique_constraint(:name, name: "templates_name_index")
    |> unsafe_validate_unique([:name, :mud_id], Exmud.Repo)
    |> foreign_key_constraint(:mud_id)
  end
end

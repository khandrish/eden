defmodule Exmud.Engine.Template do
  use Ecto.Schema
  import Ecto.Changeset

  schema "templates" do
    field :name, :binary
    belongs_to :mud, Exmud.Engine.Mud
    has_many :callbacks, Exmud.Engine.TemplateCallback

    timestamps()
  end

  @doc false
  def changeset(template, attrs) do
    template
    |> cast(attrs, [:name, :mud_id])
    |> validate_required([:name])
    |> unique_constraint(:name)
    |> unsafe_validate_unique([:name], Exmud.Repo)
    |> foreign_key_constraint(:mud_id)
  end
end

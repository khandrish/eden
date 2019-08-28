defmodule Exmud.Prototype.Prototype do
  use Ecto.Schema
  import Ecto.Changeset

  schema "prototypes" do
    field :name, :string
    belongs_to :prototype_category, Exmud.Prototype.PrototypeCategory
    belongs_to :prototype_type, Exmud.Prototype.PrototypeType
    has_one :prototype_template, Exmud.Prototype.PrototypeTemplate
    has_one :template, through: [:prototype_template, :template]

    has_many :prototype_decorator, Exmud.Prototype.PrototypeDecorator
    has_many :decorator, through: [:prototype_decorator, :decorator]

    timestamps()
  end

  @doc false
  def changeset(prototype, attrs) do
    prototype
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end

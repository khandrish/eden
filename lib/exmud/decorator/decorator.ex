defmodule Exmud.Decorator.Decorator do
  use Ecto.Schema
  import Ecto.Changeset

  schema "decorators" do
    field :name, :string
    belongs_to :decorator_category, Exmud.Decorator.DecoratorCategory
    belongs_to :decorator_type, Exmud.Decorator.DecoratorType

    timestamps()
  end

  @doc false
  def changeset(decorator, attrs) do
    decorator
    |> cast(attrs, [:name, :decorator_category_id, :decorator_type_id])
    |> validate_required([:name, :decorator_category_id, :decorator_type_id])
  end
end

defmodule Exmud.Prototype.PrototypeDecorator do
  use Ecto.Schema
  import Ecto.Changeset

  schema "prototype_decorators" do
    belongs_to :decorator, Exmud.Decorator.Decorator
    belongs_to :prototype, Exmud.Prototype.Prototype
    has_many :prototype_decorator_callbacks, Exmud.Prototype.PrototypeDecoratorCallback
    has_many :callbacks, through: [:prototype_decorator_callbacks, :callback]

    timestamps()
  end

  @doc false
  def changeset(prototype_decorator, attrs) do
    prototype_decorator
    |> cast(attrs, [:decorator_id, :prototype_id])
    |> validate_required([:decorator_id, :prototype_id])
  end
end

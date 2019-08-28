defmodule Exmud.Prototype.PrototypeDecoratorCallback do
  use Ecto.Schema
  import Ecto.Changeset

  schema "prototype_decorator_callbacks" do
    field :default_config, :map
    belongs_to :callback, Exmud.Engine.Callback
    belongs_to :prototype_decorator, Exmud.Prototype.PrototypeDecorator

    timestamps()
  end

  @doc false
  def changeset(prototype_decorator_callback, attrs) do
    prototype_decorator_callback
    |> cast(attrs, [:callback_id, :default_config, :prototype_decorator_id])
    |> validate_required([:callback_id, :default_config, :prototype_decorator_id])
  end
end

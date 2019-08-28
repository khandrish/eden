defmodule Exmud.Decorator.DecoratorCallback do
  use Ecto.Schema
  import Ecto.Changeset

  schema "decorator_callbacks" do
    field :default_config, :map
    belongs_to :decorator, Exmud.Decorator.Decorator
    belongs_to :callback, Exmud.Engine.Callback

    timestamps()
  end

  @doc false
  def changeset(decorator_callback, attrs) do
    decorator_callback
    |> cast(attrs, [:default_config])
    |> validate_required([:default_config])
  end
end

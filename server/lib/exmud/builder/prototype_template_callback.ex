defmodule Exmud.Builder.PrototypeTemplateCallback do
  use Ecto.Schema
  import Ecto.Changeset

  schema "prototype_template_callbacks" do
    field :config, :map
    belongs_to :prototype_template, Exmud.Builder.PrototypeTemplate

    timestamps()
  end

  @doc false
  def changeset(prototype_template_callback, attrs) do
    prototype_template_callback
    |> cast(attrs, [:config])
    |> validate_required([:config])
  end
end

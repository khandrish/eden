defmodule Exmud.Prototype.PrototypeTemplateCallback do
  use Ecto.Schema
  import Ecto.Changeset

  schema "prototype_template_callbacks" do
    field :default_config, :map
    belongs_to :callback, Exmud.Engine.Callback
    belongs_to :prototype_template, Exmud.Prototype.PrototypeTemplate

    timestamps()
  end

  @doc false
  def changeset(prototype_template_callback, attrs) do
    prototype_template_callback
    |> cast(attrs, [:callback_id, :default_config, :prototype_template_id])
    |> validate_required([:callback_id, :default_config, :prototype_template_id])
  end
end

defmodule Exmud.Template.TemplateCallback do
  use Ecto.Schema
  import Ecto.Changeset

  schema "template_callbacks" do
    field :default_config, :map
    belongs_to :template, Exmud.Template.Template
    belongs_to :callback, Exmud.Engine.Callback

    timestamps()
  end

  @doc false
  def changeset(template_callback, attrs) do
    template_callback
    |> cast(attrs, [:default_config, :template_id, :callback_id])
    |> validate_required([:default_config])
    |> foreign_key_constraint(:template_id)
    |> foreign_key_constraint(:callback_id)
  end
end

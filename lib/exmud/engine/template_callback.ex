defmodule Exmud.Engine.TemplateCallback do
  use Ecto.Schema
  import Ecto.Changeset

  schema "template_callbacks" do
    field :default_config, :map
    belongs_to :template, Exmud.Engine.Template
    belongs_to :simulation_callback, Exmud.Engine.SimulationCallback

    timestamps()
  end

  @doc false
  def changeset(template_callback, attrs) do
    template_callback
    |> cast(attrs, [:default_config, :template_id, :simulation_callback_id])
    |> validate_required([:default_config])
    |> foreign_key_constraint(:template_id)
    |> foreign_key_constraint(:simulation_callback_id)
    |> unique_constraint(:template_id, name: "template_callback_index")
  end
end

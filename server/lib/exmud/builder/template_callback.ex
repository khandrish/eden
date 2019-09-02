defmodule Exmud.Builder.TemplateCallback do
  use Ecto.Schema
  import Ecto.Changeset

  schema "template_callbacks" do
    field :config, :map
    field :priority, :integer
    field :template_id, :id
    field :callback_id, :id

    timestamps()
  end

  @doc false
  def changeset(template_callback, attrs) do
    template_callback
    |> cast(attrs, [:config])
    |> validate_required([:config])
  end
end

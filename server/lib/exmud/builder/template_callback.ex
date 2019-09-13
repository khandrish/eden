defmodule Exmud.Builder.TemplateCallback do
  use Ecto.Schema
  import Ecto.Changeset

  @timestamps_opts [type: :utc_datetime_usec]
  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "template_callbacks" do
    field :config, :map
    field :priority, :integer
    belongs_to :callback, Exmud.Builder.Callback
    belongs_to :template, Exmud.Builder.Template

    timestamps()
  end

  @doc false
  def changeset(template_callback, attrs) do
    template_callback
    |> cast(attrs, [:config])
    |> validate_required([:config])
  end
end

defmodule Exmud.Template.TemplateDecorator do
  use Ecto.Schema
  import Ecto.Changeset

  schema "template_decorators" do
    belongs_to :template, Exmud.Template.Template
    belongs_to :decorator, Exmud.Decorator.Decorator

    timestamps()
  end

  @doc false
  def changeset(template_decorator, attrs) do
    template_decorator
    |> cast(attrs, [])
    |> validate_required([])
  end
end

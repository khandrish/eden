defmodule Exmud.Template.TemplateCategory do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query, warn: false

  schema "template_categories" do
    field :name, :string
    belongs_to :mud, Exmud.Engine.Mud

    timestamps()
  end

  @spec delete_by_name(binary) :: :ok
  def delete_by_name(name) when is_binary(name) do
    from(
      category in __MODULE__,
      where: category.name == ^name
    )
    |> Exmud.Repo.delete_all()

    :ok
  end

  @spec changeset({map, any} | %{__struct__: atom | %{__changeset__: any}}) :: Ecto.Changeset.t()
  def changeset(template_category), do: change(template_category)

  @doc false
  @spec changeset(Exmud.Template.TemplateCategory.t(), map()) :: Ecto.Changeset.t()
  def changeset(template_category = %__MODULE__{}, attrs) when is_map(attrs) do
    template_category
    |> cast(attrs, [:mud_id, :name])
    |> validate_required([:mud_id, :name])
    |> validate_length(:name, min: 1, max: 30)
    |> unique_constraint(:name)
    |> unsafe_validate_unique(:name, Exmud.Repo, name: "template_categories_mud_index")
  end

  @spec new :: Exmud.Template.TemplateCategory.t()
  def new do
    %__MODULE__{}
  end
end

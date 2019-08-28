defmodule Exmud.Template.TemplateType do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query, warn: false

  schema "template_types" do
    field(:name, :string)
    belongs_to :mud, Exmud.Engine.Mud

    timestamps()
  end

  @spec delete_by_name(binary) :: :ok
  def delete_by_name(name) when is_binary(name) do
    from(
      type in __MODULE__,
      where: type.name == ^name
    )
    |> Exmud.Repo.delete_all()

    :ok
  end

  @spec changeset({map, any} | %{__struct__: atom | %{__changeset__: any}}) :: Ecto.Changeset.t()
  def changeset(template_type), do: change(template_type)

  @doc false
  @spec changeset(Exmud.Template.TemplateType.t(), map()) :: Ecto.Changeset.t()
  def changeset(template_type = %__MODULE__{}, attrs) when is_map(attrs) do
    template_type
    |> cast(attrs, [:mud_id, :name])
    |> validate_required([:mud_id, :name])
    |> validate_length(:name, min: 1, max: 30)
    |> unique_constraint(:name)
    |> unsafe_validate_unique(:name, Exmud.Repo, name: "template_type_mud_index")
  end

  @spec new :: Exmud.Template.TemplateType.t()
  def new do
    %__MODULE__{}
  end
end

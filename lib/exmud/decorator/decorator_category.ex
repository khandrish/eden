defmodule Exmud.Decorator.DecoratorCategory do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query, warn: false

  schema "decorator_categories" do
    field :name, :string
    field :mud_id, :id

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
  def changeset(decorator_category), do: change(decorator_category)

  @doc false
  def changeset(decorator_category, attrs) do
    decorator_category
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end

  @spec new :: Exmud.Decorator.DecoratorCategory.t()
  def new do
    %__MODULE__{}
  end
end

defmodule Exmud.Decorator.DecoratorType do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query, warn: false

  schema "decorator_types" do
    field :name, :string
    field :mud_id, :id

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
  def changeset(decorator_type), do: change(decorator_type)

  @doc false
  def changeset(decorator_type, attrs) do
    decorator_type
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end

  @spec new :: Exmud.Decorator.DecoratorType.t()
  def new do
    %__MODULE__{}
  end
end

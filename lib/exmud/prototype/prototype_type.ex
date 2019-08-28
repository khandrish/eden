defmodule Exmud.Prototype.PrototypeType do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query, warn: false

  schema "prototype_types" do
    field :name, :string
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
  def changeset(prototype_type), do: change(prototype_type)

  @doc false
  def changeset(prototype_type, attrs) do
    prototype_type
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end

  @spec new :: Exmud.Prototype.PrototypeType.t()
  def new do
    %__MODULE__{}
  end
end

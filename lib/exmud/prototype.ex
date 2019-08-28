defmodule Exmud.Prototype do
  @moduledoc """
  The Prototype context.
  """

  import Ecto.Query, warn: false
  alias Exmud.Repo

  alias Exmud.Prototype.Prototype

  @doc """
  Returns the list of prototypes.

  ## Examples

      iex> list_prototypes()
      [%Prototype{}, ...]

  """
  def list_prototypes do
    Repo.all(Prototype)
  end

  @doc """
  Gets a single prototype.

  Raises `Ecto.NoResultsError` if the Prototype does not exist.

  ## Examples

      iex> get_prototype!(123)
      %Prototype{}

      iex> get_prototype!(456)
      ** (Ecto.NoResultsError)

  """
  def get_prototype!(id), do: Repo.get!(Prototype, id)

  @doc """
  Creates a prototype.

  ## Examples

      iex> create_prototype(%{field: value})
      {:ok, %Prototype{}}

      iex> create_prototype(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_prototype(attrs \\ %{}) do
    %Prototype{}
    |> Prototype.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a prototype.

  ## Examples

      iex> update_prototype(prototype, %{field: new_value})
      {:ok, %Prototype{}}

      iex> update_prototype(prototype, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_prototype(%Prototype{} = prototype, attrs) do
    prototype
    |> Prototype.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Prototype.

  ## Examples

      iex> delete_prototype(prototype)
      {:ok, %Prototype{}}

      iex> delete_prototype(prototype)
      {:error, %Ecto.Changeset{}}

  """
  def delete_prototype(%Prototype{} = prototype) do
    Repo.delete(prototype)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking prototype changes.

  ## Examples

      iex> change_prototype(prototype)
      %Ecto.Changeset{source: %Prototype{}}

  """
  def change_prototype(%Prototype{} = prototype) do
    Prototype.changeset(prototype, %{})
  end

  alias Exmud.Prototype.PrototypeCategory

  @doc """
  Returns the list of prototype_categories.

  ## Examples

      iex> list_prototype_categories()
      [%PrototypeCategory{}, ...]

  """
  def list_prototype_categories do
    Repo.all(PrototypeCategory)
  end

  @doc """
  Gets a single prototype_category.

  Raises `Ecto.NoResultsError` if the Prototype category does not exist.

  ## Examples

      iex> get_prototype_category!(123)
      %PrototypeCategory{}

      iex> get_prototype_category!(456)
      ** (Ecto.NoResultsError)

  """
  def get_prototype_category!(id), do: Repo.get!(PrototypeCategory, id)

  @doc """
  Creates a prototype_category.

  ## Examples

      iex> create_prototype_category(%{field: value})
      {:ok, %PrototypeCategory{}}

      iex> create_prototype_category(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_prototype_category(attrs \\ %{}) do
    %PrototypeCategory{}
    |> PrototypeCategory.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a prototype_category.

  ## Examples

      iex> update_prototype_category(prototype_category, %{field: new_value})
      {:ok, %PrototypeCategory{}}

      iex> update_prototype_category(prototype_category, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_prototype_category(%PrototypeCategory{} = prototype_category, attrs) do
    prototype_category
    |> PrototypeCategory.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a PrototypeCategory.

  ## Examples

      iex> delete_prototype_category(prototype_category)
      {:ok, %PrototypeCategory{}}

      iex> delete_prototype_category(prototype_category)
      {:error, %Ecto.Changeset{}}

  """
  def delete_prototype_category(%PrototypeCategory{} = prototype_category) do
    Repo.delete(prototype_category)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking prototype_category changes.

  ## Examples

      iex> change_prototype_category(prototype_category)
      %Ecto.Changeset{source: %PrototypeCategory{}}

  """
  def change_prototype_category(%PrototypeCategory{} = prototype_category) do
    PrototypeCategory.changeset(prototype_category, %{})
  end

  alias Exmud.Prototype.PrototypeType

  @doc """
  Returns the list of prototype_types.

  ## Examples

      iex> list_prototype_types()
      [%PrototypeType{}, ...]

  """
  def list_prototype_types do
    Repo.all(PrototypeType)
  end

  @doc """
  Gets a single prototype_type.

  Raises `Ecto.NoResultsError` if the Prototype type does not exist.

  ## Examples

      iex> get_prototype_type!(123)
      %PrototypeType{}

      iex> get_prototype_type!(456)
      ** (Ecto.NoResultsError)

  """
  def get_prototype_type!(id), do: Repo.get!(PrototypeType, id)

  @doc """
  Creates a prototype_type.

  ## Examples

      iex> create_prototype_type(%{field: value})
      {:ok, %PrototypeType{}}

      iex> create_prototype_type(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_prototype_type(attrs \\ %{}) do
    %PrototypeType{}
    |> PrototypeType.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a prototype_type.

  ## Examples

      iex> update_prototype_type(prototype_type, %{field: new_value})
      {:ok, %PrototypeType{}}

      iex> update_prototype_type(prototype_type, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_prototype_type(%PrototypeType{} = prototype_type, attrs) do
    prototype_type
    |> PrototypeType.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a PrototypeType.

  ## Examples

      iex> delete_prototype_type(prototype_type)
      {:ok, %PrototypeType{}}

      iex> delete_prototype_type(prototype_type)
      {:error, %Ecto.Changeset{}}

  """
  def delete_prototype_type(%PrototypeType{} = prototype_type) do
    Repo.delete(prototype_type)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking prototype_type changes.

  ## Examples

      iex> change_prototype_type(prototype_type)
      %Ecto.Changeset{source: %PrototypeType{}}

  """
  def change_prototype_type(%PrototypeType{} = prototype_type) do
    PrototypeType.changeset(prototype_type, %{})
  end
end

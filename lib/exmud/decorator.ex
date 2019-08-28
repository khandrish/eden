defmodule Exmud.Decorator do
  @moduledoc """
  The Decorator context.
  """

  import Ecto.Query, warn: false
  alias Exmud.Repo

  alias Exmud.Decorator.DecoratorCategory

  @doc """
  Returns the list of decorator_categories for a specific Mud.

  ## Examples

      iex> list_decorator_categories(42)
      [%DecoratorCategory{}, ...]

  """
  def list_decorator_categories(id) do
    Repo.all(
      from(dc in DecoratorCategory,
        where: dc.mud_id == ^id
      )
    )
  end

  @doc """
  Gets a single decorator_category.

  Raises `Ecto.NoResultsError` if the Decorator category does not exist.

  ## Examples

      iex> get_decorator_category!(123)
      %DecoratorCategory{}

      iex> get_decorator_category!(456)
      ** (Ecto.NoResultsError)

  """
  def get_decorator_category!(id), do: Repo.get!(DecoratorCategory, id)

  @doc """
  Creates a decorator_category.

  ## Examples

      iex> create_decorator_category(%{field: value})
      {:ok, %DecoratorCategory{}}

      iex> create_decorator_category(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_decorator_category(attrs \\ %{}) do
    %DecoratorCategory{}
    |> DecoratorCategory.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a decorator_category.

  ## Examples

      iex> update_decorator_category(decorator_category, %{field: new_value})
      {:ok, %DecoratorCategory{}}

      iex> update_decorator_category(decorator_category, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_decorator_category(%DecoratorCategory{} = decorator_category, attrs) do
    decorator_category
    |> DecoratorCategory.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a DecoratorCategory.

  ## Examples

      iex> delete_decorator_category(decorator_category)
      {:ok, %DecoratorCategory{}}

      iex> delete_decorator_category(decorator_category)
      {:error, %Ecto.Changeset{}}

  """
  def delete_decorator_category(%DecoratorCategory{} = decorator_category) do
    Repo.delete(decorator_category)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking decorator_category changes.

  ## Examples

      iex> change_decorator_category(decorator_category)
      %Ecto.Changeset{source: %DecoratorCategory{}}

  """
  def change_decorator_category(%DecoratorCategory{} = decorator_category) do
    DecoratorCategory.changeset(decorator_category, %{})
  end

  alias Exmud.Decorator.DecoratorType

  @doc """
  Returns the list of decorator_types for a specific Mud.

  ## Examples

      iex> list_decorator_types(42)
      [%DecoratorType{}, ...]

  """
  def list_decorator_types(id) do
    Repo.all(
      from(dt in DecoratorType,
        where: dt.mud_id == ^id
      )
    )
  end

  @doc """
  Gets a single decorator_type.

  Raises `Ecto.NoResultsError` if the Decorator type does not exist.

  ## Examples

      iex> get_decorator_type!(123)
      %DecoratorType{}

      iex> get_decorator_type!(456)
      ** (Ecto.NoResultsError)

  """
  def get_decorator_type!(id), do: Repo.get!(DecoratorType, id)

  @doc """
  Creates a decorator_type.

  ## Examples

      iex> create_decorator_type(%{field: value})
      {:ok, %DecoratorType{}}

      iex> create_decorator_type(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_decorator_type(attrs \\ %{}) do
    %DecoratorType{}
    |> DecoratorType.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a decorator_type.

  ## Examples

      iex> update_decorator_type(decorator_type, %{field: new_value})
      {:ok, %DecoratorType{}}

      iex> update_decorator_type(decorator_type, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_decorator_type(%DecoratorType{} = decorator_type, attrs) do
    decorator_type
    |> DecoratorType.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a DecoratorType.

  ## Examples

      iex> delete_decorator_type(decorator_type)
      {:ok, %DecoratorType{}}

      iex> delete_decorator_type(decorator_type)
      {:error, %Ecto.Changeset{}}

  """
  def delete_decorator_type(%DecoratorType{} = decorator_type) do
    Repo.delete(decorator_type)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking decorator_type changes.

  ## Examples

      iex> change_decorator_type(decorator_type)
      %Ecto.Changeset{source: %DecoratorType{}}

  """
  def change_decorator_type(%DecoratorType{} = decorator_type) do
    DecoratorType.changeset(decorator_type, %{})
  end
end

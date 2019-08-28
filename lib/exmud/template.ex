defmodule Exmud.Template do
  @moduledoc """
  The Template context.
  """

  import Ecto.Query, warn: false
  alias Exmud.Repo

  alias Exmud.Template.TemplateCategory

  @doc """
  Returns the list of template_categories for a specific MUD.

  ## Examples

      iex> list_template_categories(42)
      [%TemplateCategory{}, ...]

  """
  def list_template_categories(id) do
    Repo.all(
      from(tc in TemplateCategory,
        where: tc.mud_id == ^id
      )
    )
  end

  @doc """
  Gets a single template_category.

  Raises `Ecto.NoResultsError` if the Template category does not exist.

  ## Examples

      iex> get_template_category!(123)
      %TemplateCategory{}

      iex> get_template_category!(456)
      ** (Ecto.NoResultsError)

  """
  def get_template_category!(id), do: Repo.get!(TemplateCategory, id)

  @doc """
  Creates a template_category.

  ## Examples

      iex> create_template_category(%{field: value})
      {:ok, %TemplateCategory{}}

      iex> create_template_category(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_template_category(attrs \\ %{}) do
    %TemplateCategory{}
    |> TemplateCategory.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a template_category.

  ## Examples

      iex> update_template_category(template_category, %{field: new_value})
      {:ok, %TemplateCategory{}}

      iex> update_template_category(template_category, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_template_category(%TemplateCategory{} = template_category, attrs) do
    template_category
    |> TemplateCategory.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a TemplateCategory.

  ## Examples

      iex> delete_template_category(template_category)
      {:ok, %TemplateCategory{}}

      iex> delete_template_category(template_category)
      {:error, %Ecto.Changeset{}}

  """
  def delete_template_category(%TemplateCategory{} = template_category) do
    Repo.delete(template_category)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking template_category changes.

  ## Examples

      iex> change_template_category(template_category)
      %Ecto.Changeset{source: %TemplateCategory{}}

  """
  def change_template_category(%TemplateCategory{} = template_category) do
    TemplateCategory.changeset(template_category, %{})
  end

  alias Exmud.Template.TemplateType

  @doc """
  Returns the list of template_types for a specific MUD.

  ## Examples

      iex> list_template_types(42)
      [%TemplateType{}, ...]

  """
  def list_template_types(id) do
    Repo.all(
      from(tt in TemplateType,
        where: tt.mud_id == ^id
      )
    )
  end

  @doc """
  Gets a single template_type.

  Raises `Ecto.NoResultsError` if the Template type does not exist.

  ## Examples

      iex> get_template_type!(123)
      %TemplateType{}

      iex> get_template_type!(456)
      ** (Ecto.NoResultsError)

  """
  def get_template_type!(id), do: Repo.get!(TemplateType, id)

  @doc """
  Creates a template_type.

  ## Examples

      iex> create_template_type(%{field: value})
      {:ok, %TemplateType{}}

      iex> create_template_type(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_template_type(attrs \\ %{}) do
    %TemplateType{}
    |> TemplateType.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a template_type.

  ## Examples

      iex> update_template_type(template_type, %{field: new_value})
      {:ok, %TemplateType{}}

      iex> update_template_type(template_type, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_template_type(%TemplateType{} = template_type, attrs) do
    template_type
    |> TemplateType.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a TemplateType.

  ## Examples

      iex> delete_template_type(template_type)
      {:ok, %TemplateType{}}

      iex> delete_template_type(template_type)
      {:error, %Ecto.Changeset{}}

  """
  def delete_template_type(%TemplateType{} = template_type) do
    Repo.delete(template_type)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking template_type changes.

  ## Examples

      iex> change_template_type(template_type)
      %Ecto.Changeset{source: %TemplateType{}}

  """
  def change_template_type(%TemplateType{} = template_type) do
    TemplateType.changeset(template_type, %{})
  end
end

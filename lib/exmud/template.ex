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

  alias Exmud.Template.Template

  @doc """
  Returns the list of templates.

  ## Examples

      iex> list_templates()
      [%Template{}, ...]

  """
  def list_templates do
    Repo.all(
      from(
        template in Template,
        left_join: mud in assoc(template, :mud),
        preload: [:mud]
      )
    )
  end

  @doc """
  Returns the list of templates for a specific mud.

  ## Examples

      iex> list_templates(42)
      [%Template{}, ...]

  """
  def list_templates(id) do
    Repo.all(
      from(
        template in Template,
        where: template.mud_id == ^id,
        left_join: mud in assoc(template, :mud),
        preload: [:mud]
      )
    )
  end

  @doc """
  Gets a single template.

  Raises `Ecto.NoResultsError` if the Template does not exist.

  ## Examples

      iex> get_template!(123)
      %Template{}

      iex> get_template!(456)
      ** (Ecto.NoResultsError)

  """
  def get_template!(id) do
    Repo.one!(
      from(
        template in Template,
        where: template.id == ^id,
        left_join: mud in assoc(template, :mud),
        preload: [:mud]
      )
    )
  end

  @doc """
  Creates a template.

  ## Examples

      iex> create_template(%{field: value})
      {:ok, %Template{}}

      iex> create_template(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_template(attrs \\ %{}) do
    %Template{}
    |> Template.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a template.

  ## Examples

      iex> update_template(template, %{field: new_value})
      {:ok, %Template{}}

      iex> update_template(template, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_template(%Template{} = template, attrs) do
    template
    |> Template.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Template.

  ## Examples

      iex> delete_template(template)
      {:ok, %Template{}}

      iex> delete_template(template)
      {:error, %Ecto.Changeset{}}

  """
  def delete_template(%Template{} = template) do
    Repo.delete(template)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking template changes.

  ## Examples

      iex> change_template(template)
      %Ecto.Changeset{source: %Template{}}

  """
  def change_template(%Template{} = template) do
    Template.changeset(template, %{})
  end

  alias Exmud.Template.TemplateCallback

  @doc """
  Returns the list of template_callbacks.

  ## Examples

      iex> list_template_callbacks()
      [%TemplateCallback{}, ...]

  """
  def list_template_callbacks do
    Repo.all(TemplateCallback)
  end

  @doc """
  Returns the list of template_callbacks for a specific template.

  ## Examples

      iex> list_template_callbacks(42)
      [%TemplateCallback{}, ...]

  """
  def list_template_callbacks(template_id) do
    Repo.all(
      from(
        template_callback in TemplateCallback,
        where: template_callback.template_id == ^template_id,
        left_join: mud_callback in assoc(template_callback, :mud_callback),
        left_join: callback in assoc(mud_callback, :callback),
        preload: [:template, mud_callback: {mud_callback, callback: callback}]
      )
    )
  end

  @doc """
  Gets a single template_callback.

  Raises `Ecto.NoResultsError` if the Template callback does not exist.

  ## Examples

      iex> get_template_callback!(123)
      %TemplateCallback{}

      iex> get_template_callback!(456)
      ** (Ecto.NoResultsError)

  """
  def get_template_callback!(id) do
    Repo.one!(
      from(tc in TemplateCallback,
        where: tc.id == ^id,
        preload: [:callback, :template]
      )
    )
  end

  @doc """
  Creates a template_callback.

  ## Examples

      iex> create_template_callback(%{field: value})
      {:ok, %TemplateCallback{}}

      iex> create_template_callback(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_template_callback(attrs \\ %{}) do
    %TemplateCallback{}
    |> TemplateCallback.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Creates a template_callback.

  ## Examples

      iex> create_template_callback!(%{field: value})
      {:ok, %TemplateCallback{}}

  """
  def create_template_callback!(attrs \\ %{}) do
    %TemplateCallback{}
    |> TemplateCallback.changeset(attrs)
    |> Repo.insert!()
  end

  @doc """
  Updates a template_callback.

  ## Examples

      iex> update_template_callback(template_callback, %{field: new_value})
      {:ok, %TemplateCallback{}}

      iex> update_template_callback(template_callback, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_template_callback(%TemplateCallback{} = template_callback, attrs) do
    template_callback
    |> TemplateCallback.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a TemplateCallback.

  ## Examples

      iex> delete_template_callback(template_callback)
      {:ok, %TemplateCallback{}}

      iex> delete_template_callback(template_callback)
      {:error, %Ecto.Changeset{}}

  """
  def delete_template_callback(%TemplateCallback{} = template_callback) do
    Repo.delete(template_callback)
  end

  @doc """
  Delete a template <-> callback association.
  """
  def delete_template_callback!(callback_id, template_id) do
    result =
      Repo.delete_all(
        from(
          cb in TemplateCallback,
          where: cb.callback_id == ^callback_id and cb.template_id == ^template_id
        )
      )

    case result do
      {1, _} ->
        :ok

      _ ->
        raise ArgumentError
    end

    :ok
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking template_callback changes.

  ## Examples

      iex> change_template_callback(template_callback)
      %Ecto.Changeset{source: %TemplateCallback{}}

  """
  def change_template_callback(%TemplateCallback{} = template_callback) do
    TemplateCallback.changeset(template_callback, %{})
  end
end

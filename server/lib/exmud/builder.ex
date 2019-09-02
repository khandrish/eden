defmodule Exmud.Builder do
  @moduledoc """
  The Builder context.
  """

  import Ecto.Query, warn: false
  alias Exmud.Repo

  alias Exmud.Builder.Category

  @doc """
  Returns the list of categories.

  ## Examples

      iex> list_categories()
      [%Category{}, ...]

  """
  def list_categories do
    Repo.all(Category)
  end

  @doc """
  Gets a single category.

  Raises `Ecto.NoResultsError` if the Category does not exist.

  ## Examples

      iex> get_category!(123)
      %Category{}

      iex> get_category!(456)
      ** (Ecto.NoResultsError)

  """
  def get_category!(id), do: Repo.get!(Category, id)

  @doc """
  Gets a single category via its slug.

  Raises `Ecto.NoResultsError` if the Category does not exist.

  ## Examples

      iex> get_category_by_slug!("banana")
      %Category{}

      iex> get_category_by_slug!("not a")
      ** (Ecto.NoResultsError)

  """
  def get_category_by_slug!(slug) do
    Repo.one!(
      from(category in Category,
        where: category.slug == ^slug
      )
    )
  end

  @doc """
  Creates a category.

  ## Examples

      iex> create_category(%{field: value})
      {:ok, %Category{}}

      iex> create_category(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_category(attrs \\ %{}) do
    %Category{}
    |> Category.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a category.

  ## Examples

      iex> update_category(category, %{field: new_value})
      {:ok, %Category{}}

      iex> update_category(category, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_category(%Category{} = category, attrs) do
    category
    |> Category.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Category.

  ## Examples

      iex> delete_category(category)
      {:ok, %Category{}}

      iex> delete_category(category)
      {:error, %Ecto.Changeset{}}

  """
  def delete_category(%Category{} = category) do
    Repo.delete(category)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking category changes.

  ## Examples

      iex> change_category(category)
      %Ecto.Changeset{source: %Category{}}

  """
  def change_category(%Category{} = category) do
    Category.changeset(category, %{})
  end

  alias Exmud.Builder.Template

  @doc """
  Gets a single template.

  Raises `Ecto.NoResultsError` if the Template does not exist.

  ## Examples

      iex> get_template!(123)
      %Template{}

      iex> get_template!(456)
      ** (Ecto.NoResultsError)

  """
  def get_template!(id), do: Repo.get!(Template, id)

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

  alias Exmud.Builder.Prototype

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

  alias Exmud.Builder.Callback

  @doc """
  Returns the list of callbacks.

  ## Examples

      iex> list_callbacks()
      [%Callback{}, ...]

  """
  def list_callbacks do
    Repo.all(Callback)
    |> Enum.map(fn callback ->
      %{
        callback
        | config_schema: callback.module.config_schema(),
          docs: Exmud.Util.get_module_docs(callback.module)
      }
    end)
  end

  @doc """
  Gets a single callback.

  Raises `Ecto.NoResultsError` if the Callback does not exist.

  ## Examples

      iex> get_callback!(123)
      %Callback{}

      iex> get_callback!(456)
      ** (Ecto.NoResultsError)

  """
  def get_callback!(id) do
    callback = Repo.get!(Callback, id)

    %{
      callback
      | config_schema: callback.module.config_schema(),
        docs: Exmud.Util.get_module_docs(callback.module)
    }
  end

  @doc """
  Creates a callback.

  ## Examples

      iex> create_callback(%{field: value})
      {:ok, %Callback{}}

      iex> create_callback(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_callback(attrs \\ %{}) do
    %Callback{}
    |> Callback.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a callback.

  ## Examples

      iex> update_callback(callback, %{field: new_value})
      {:ok, %Callback{}}

      iex> update_callback(callback, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_callback(%Callback{} = callback, attrs) do
    callback
    |> Callback.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Callback.

  ## Examples

      iex> delete_callback(callback)
      {:ok, %Callback{}}

      iex> delete_callback(callback)
      {:error, %Ecto.Changeset{}}

  """
  def delete_callback(%Callback{} = callback) do
    Repo.delete(callback)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking callback changes.

  ## Examples

      iex> change_callback(callback)
      %Ecto.Changeset{source: %Callback{}}

  """
  def change_callback(%Callback{} = callback) do
    Callback.changeset(callback, %{})
  end

  alias Exmud.Engine.Mud

  @doc """
  Returns the list of muds.

  ## Examples

      iex> list_muds()
      [%Engine{}, ...]

  """
  def list_muds do
    Repo.all(Engine)
  end

  @doc """
  Gets a single mud.

  Raises `Ecto.NoResultsError` if the Engine does not exist.

  ## Examples

      iex> get_mud!(42)
      %Engine{}

      iex> get_mud!(24)
      ** (Ecto.NoResultsError)

  """
  def get_mud!(id) do
    Exmud.Repo.get!(Engine, id)
  end

  @doc """
  Gets a single mud.

  Raises `Ecto.NoResultsError` if the Engine does not exist.

  ## Examples

      iex> get_mud_by_slug!("banana")
      %Engine{}

      iex> get_mud_by_slug!("not a")
      ** (Ecto.NoResultsError)

  """
  def get_mud_by_slug!(slug) do
    Exmud.Repo.one!(
      from mud in Mud,
        where: mud.slug == ^slug,
        preload: :callbacks
    )
  end

  @doc """
  Creates a mud.

  ## Examples

      iex> create_mud(%{field: value})
      {:ok, %Engine{}}

      iex> create_mud(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_mud(attrs \\ %{}) do
    %Mud{}
    |> Mud.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a mud.

  ## Examples

      iex> update_mud(mud, %{field: new_value})
      {:ok, %Engine{}}

      iex> update_mud(mud, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_mud(%Mud{} = mud, attrs) do
    mud
    |> Mud.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Engine.

  ## Examples

      iex> delete_mud(mud)
      {:ok, %Engine{}}

      iex> delete_mud(mud)
      {:error, %Ecto.Changeset{}}

  """
  def delete_mud(%Mud{} = mud) do
    Repo.delete(mud)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking mud changes.

  ## Examples

      iex> change_mud(mud)
      %Ecto.Changeset{source: %Engine{}}

  """
  def change_mud(%Mud{} = mud) do
    Mud.changeset(mud, %{})
  end

  alias Exmud.Engine.MudCallback

  @doc """
  Returns the list of mud_callbacks for a specific mud.

  ## Examples

      iex> list_mud_callbacks(42)
      [%MudCallback{}, ...]

  """
  def list_mud_callbacks(mud_id) do
    Repo.all(
      from(
        sim_callback in MudCallback,
        where: sim_callback.mud_id == ^mud_id,
        preload: [:mud, :callback]
      )
    )
    |> Enum.map(fn sc ->
      %{
        sc
        | callback: %{
            sc.callback
            | config_schema: sc.callback.module.config_schema(),
              docs: Exmud.Util.get_module_docs(sc.callback.module)
          }
      }
    end)
  end

  @doc """
  Gets a single mud_callback.

  Raises `Ecto.NoResultsError` if the Engine callback does not exist.

  ## Examples

      iex> get_mud_callback!(123)
      %MudCallback{}

      iex> get_mud_callback!(456)
      ** (Ecto.NoResultsError)

  """
  def get_mud_callback!(id) do
    sc =
      Repo.one!(
        from(sc in MudCallback,
          where: sc.id == ^id,
          preload: [:callback, :mud]
        )
      )

    %{
      sc
      | callback: %{
          sc.callback
          | config_schema: sc.callback.module.config_schema(),
            docs: Exmud.Util.get_module_docs(sc.callback.module)
        }
    }
  end

  @doc """
  Creates a mud_callback.

  ## Examples

      iex> create_mud_callback(%{field: value})
      {:ok, %MudCallback{}}

      iex> create_mud_callback(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_mud_callback(attrs \\ %{}) do
    %MudCallback{}
    |> MudCallback.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Creates a mud_callback, throwing an exception on failure.

  ## Examples

      iex> create_mud_callback!(%{field: value})
      %MudCallback{}

  """
  def create_mud_callback!(attrs \\ %{}) do
    %MudCallback{}
    |> MudCallback.changeset(attrs)
    |> Repo.insert!()
  end

  @doc """
  Delete a mud <-> callback association.
  """
  def delete_mud_callback!(callback_id, mud_id) do
    result =
      Repo.delete_all(
        from(
          cb in MudCallback,
          where: cb.callback_id == ^callback_id and cb.mud_id == ^mud_id
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
  Updates a mud_callback.

  ## Examples

      iex> update_mud_callback(mud_callback, %{field: new_value})
      {:ok, %MudCallback{}}

      iex> update_mud_callback(mud_callback, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_mud_callback(%MudCallback{} = mud_callback, attrs) do
    mud_callback
    |> MudCallback.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a MudCallback.

  ## Examples

      iex> delete_mud_callback(mud_callback)
      {:ok, %MudCallback{}}

      iex> delete_mud_callback(mud_callback)
      {:error, %Ecto.Changeset{}}

  """
  def delete_mud_callback(%MudCallback{} = mud_callback) do
    Repo.delete(mud_callback)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking mud_callback changes.

  ## Examples

      iex> change_mud_callback(mud_callback)
      %Ecto.Changeset{source: %MudCallback{}}

  """
  def change_mud_callback(%MudCallback{} = mud_callback) do
    MudCallback.changeset(mud_callback, %{})
  end
end

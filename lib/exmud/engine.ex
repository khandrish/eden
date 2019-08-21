defmodule Exmud.Engine do
  @moduledoc """
  The Engine context.
  """

  import Ecto.Query, warn: false
  alias Exmud.Repo

  alias Exmud.Engine.Mud

  @doc """
  Returns the list of muds.

  ## Examples

      iex> list_muds()
      [%Mud{}, ...]

  """
  def list_muds do
    Repo.all(Mud)
  end

  @doc """
  Gets a single mud.

  Raises `Ecto.NoResultsError` if the Mud does not exist.

  ## Examples

      iex> get_mud!(123)
      %Mud{}

      iex> get_mud!(456)
      ** (Ecto.NoResultsError)

  """
  def get_mud!(id) do
    Exmud.Repo.one!(
      from sim in Mud,
        where: sim.id == ^id,
        left_join: callbacks in assoc(sim, :callbacks),
        preload: [:callbacks, :templates]
    )
  end

  @doc """
  Creates a mud.

  ## Examples

      iex> create_mud(%{field: value})
      {:ok, %Mud{}}

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
      {:ok, %Mud{}}

      iex> update_mud(mud, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_mud(%Mud{} = mud, attrs) do
    mud
    |> Mud.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Mud.

  ## Examples

      iex> delete_mud(mud)
      {:ok, %Mud{}}

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
      %Ecto.Changeset{source: %Mud{}}

  """
  def change_mud(%Mud{} = mud) do
    Mud.changeset(mud, %{})
  end

  alias Exmud.Engine.Callback

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

  Raises `Ecto.NoResultsError` if the Mud callback does not exist.

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

  alias Exmud.Engine.Template

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

  alias Exmud.Engine.TemplateCallback

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

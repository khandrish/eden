defmodule Exmud.Engine do
  @moduledoc """
  The Engine context.
  """

  import Ecto.Query, warn: false
  alias Exmud.Repo

  alias Exmud.Engine.Simulation

  @doc """
  Returns the list of simulations.

  ## Examples

      iex> list_simulations()
      [%Simulation{}, ...]

  """
  def list_simulations do
    Repo.all(Simulation)
  end

  @doc """
  Gets a single simulation.

  Raises `Ecto.NoResultsError` if the Simulation does not exist.

  ## Examples

      iex> get_simulation!(123)
      %Simulation{}

      iex> get_simulation!(456)
      ** (Ecto.NoResultsError)

  """
  def get_simulation!(id) do
    Exmud.Repo.one!(
      from sim in Simulation,
        where: sim.id == ^id,
        left_join: callbacks in assoc(sim, :callbacks),
        preload: [:callbacks, :templates]
    )
  end

  @doc """
  Creates a simulation.

  ## Examples

      iex> create_simulation(%{field: value})
      {:ok, %Simulation{}}

      iex> create_simulation(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_simulation(attrs \\ %{}) do
    %Simulation{}
    |> Simulation.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a simulation.

  ## Examples

      iex> update_simulation(simulation, %{field: new_value})
      {:ok, %Simulation{}}

      iex> update_simulation(simulation, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_simulation(%Simulation{} = simulation, attrs) do
    simulation
    |> Simulation.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Simulation.

  ## Examples

      iex> delete_simulation(simulation)
      {:ok, %Simulation{}}

      iex> delete_simulation(simulation)
      {:error, %Ecto.Changeset{}}

  """
  def delete_simulation(%Simulation{} = simulation) do
    Repo.delete(simulation)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking simulation changes.

  ## Examples

      iex> change_simulation(simulation)
      %Ecto.Changeset{source: %Simulation{}}

  """
  def change_simulation(%Simulation{} = simulation) do
    Simulation.changeset(simulation, %{})
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
  def get_callback!(id), do: Repo.get!(Callback, id)

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

  alias Exmud.Engine.SimulationCallback

  @doc """
  Returns the list of simulation_callbacks for a specific simulation.

  ## Examples

      iex> list_simulation_callbacks(42)
      [%SimulationCallback{}, ...]

  """
  def list_simulation_callbacks(simulation_id) do
    Repo.all(
      from(
        sim_callback in SimulationCallback,
        where: sim_callback.simulation_id == ^simulation_id,
        preload: [:simulation, :callback]
      )
    )
  end

  @doc """
  Gets a single simulation_callback.

  Raises `Ecto.NoResultsError` if the Simulation callback does not exist.

  ## Examples

      iex> get_simulation_callback!(123)
      %SimulationCallback{}

      iex> get_simulation_callback!(456)
      ** (Ecto.NoResultsError)

  """
  def get_simulation_callback!(id) do
    Repo.one!(
      from(sc in SimulationCallback,
        where: sc.id == ^id,
        preload: [:callback, :simulation]
      )
    )
  end

  @doc """
  Creates a simulation_callback.

  ## Examples

      iex> create_simulation_callback(%{field: value})
      {:ok, %SimulationCallback{}}

      iex> create_simulation_callback(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_simulation_callback(attrs \\ %{}) do
    %SimulationCallback{}
    |> SimulationCallback.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Creates a simulation_callback, throwing an exception on failure.

  ## Examples

      iex> create_simulation_callback!(%{field: value})
      %SimulationCallback{}

  """
  def create_simulation_callback!(attrs \\ %{}) do
    %SimulationCallback{}
    |> SimulationCallback.changeset(attrs)
    |> Repo.insert!()
  end

  @doc """
  Delete a simulation <-> callback association.
  """
  def delete_simulation_callback!(callback_id, simulation_id) do
    result =
      Repo.delete_all(
        from(
          cb in SimulationCallback,
          where: cb.callback_id == ^callback_id and cb.simulation_id == ^simulation_id
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
  Updates a simulation_callback.

  ## Examples

      iex> update_simulation_callback(simulation_callback, %{field: new_value})
      {:ok, %SimulationCallback{}}

      iex> update_simulation_callback(simulation_callback, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_simulation_callback(%SimulationCallback{} = simulation_callback, attrs) do
    simulation_callback
    |> SimulationCallback.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a SimulationCallback.

  ## Examples

      iex> delete_simulation_callback(simulation_callback)
      {:ok, %SimulationCallback{}}

      iex> delete_simulation_callback(simulation_callback)
      {:error, %Ecto.Changeset{}}

  """
  def delete_simulation_callback(%SimulationCallback{} = simulation_callback) do
    Repo.delete(simulation_callback)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking simulation_callback changes.

  ## Examples

      iex> change_simulation_callback(simulation_callback)
      %Ecto.Changeset{source: %SimulationCallback{}}

  """
  def change_simulation_callback(%SimulationCallback{} = simulation_callback) do
    SimulationCallback.changeset(simulation_callback, %{})
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
        left_join: simulation in assoc(template, :simulation),
        preload: [:simulation]
      )
    )
  end

  @doc """
  Returns the list of templates for a specific simulation.

  ## Examples

      iex> list_templates(42)
      [%Template{}, ...]

  """
  def list_templates(id) do
    Repo.all(
      from(
        template in Template,
        where: template.simulation_id == ^id,
        left_join: simulation in assoc(template, :simulation),
        preload: [:simulation]
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
        left_join: simulation in assoc(template, :simulation),
        preload: [:simulation]
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
        left_join: simulation_callback in assoc(template_callback, :simulation_callback),
        left_join: callback in assoc(simulation_callback, :callback),
        preload: [:template, simulation_callback: {simulation_callback, callback: callback}]
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

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
        preload: [:callbacks]
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
  Returns the list of simulation_callbacks.

  ## Examples

      iex> list_simulation_callbacks()
      [%SimulationCallback{}, ...]

  """
  def list_simulation_callbacks do
    Repo.all(SimulationCallback)
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
  def get_simulation_callback!(id), do: Repo.get!(SimulationCallback, id)

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
end

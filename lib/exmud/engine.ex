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
  def get_simulation!(id), do: Repo.get!(Simulation, id)

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

  alias Exmud.Engine.Callbacks

  @doc """
  Returns the list of callbacks.

  ## Examples

      iex> list_callbacks()
      [%Callbacks{}, ...]

  """
  def list_callbacks do
    Repo.all(Callbacks)
  end

  @doc """
  Gets a single callbacks.

  Raises `Ecto.NoResultsError` if the Callbacks does not exist.

  ## Examples

      iex> get_callbacks!(123)
      %Callbacks{}

      iex> get_callbacks!(456)
      ** (Ecto.NoResultsError)

  """
  def get_callbacks!(id), do: Repo.get!(Callbacks, id)

  @doc """
  Creates a callbacks.

  ## Examples

      iex> create_callbacks(%{field: value})
      {:ok, %Callbacks{}}

      iex> create_callbacks(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_callbacks(attrs \\ %{}) do
    %Callbacks{}
    |> Callbacks.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a callbacks.

  ## Examples

      iex> update_callbacks(callbacks, %{field: new_value})
      {:ok, %Callbacks{}}

      iex> update_callbacks(callbacks, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_callbacks(%Callbacks{} = callbacks, attrs) do
    callbacks
    |> Callbacks.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Callbacks.

  ## Examples

      iex> delete_callbacks(callbacks)
      {:ok, %Callbacks{}}

      iex> delete_callbacks(callbacks)
      {:error, %Ecto.Changeset{}}

  """
  def delete_callbacks(%Callbacks{} = callbacks) do
    Repo.delete(callbacks)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking callbacks changes.

  ## Examples

      iex> change_callbacks(callbacks)
      %Ecto.Changeset{source: %Callbacks{}}

  """
  def change_callbacks(%Callbacks{} = callbacks) do
    Callbacks.changeset(callbacks, %{})
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

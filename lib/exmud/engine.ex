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

      iex> get_mud!(42)
      %Mud{}

      iex> get_mud!(24)
      ** (Ecto.NoResultsError)

  """
  def get_mud!(id) do
    Exmud.Repo.get!(Mud, id)
  end

  @doc """
  Gets a single mud.

  Raises `Ecto.NoResultsError` if the Mud does not exist.

  ## Examples

      iex> get_mud_by_slug!("banana")
      %Mud{}

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
end

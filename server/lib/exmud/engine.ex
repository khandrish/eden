defmodule Exmud.Engine do
  @moduledoc """
  The Engine context.
  """

  import Ecto.Query, warn: false

  alias Exmud.Account.Player
  alias Exmud.Engine.{Character, Mud}
  alias Exmud.Repo

  @doc """
  Returns the list of muds.

  ## Examples

      iex> list_muds()
      {:ok, [%Mud{}, ...]}

  """
  def list_muds do
    {:ok, Repo.all(Mud)}
  end

  @doc """
  Gets a single mud.

  ## Examples

      iex> get_mud("uuid")
      {:ok, %Mud{}}

      iex> get_mud("not a uuid")
      {:error, :not_found}

  """
  def get_mud(id) when is_binary(id) do
    case Exmud.Repo.get(Mud, id) do
      nil ->
        {:error, :not_found}

      mud ->
        {:ok, mud}
    end
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
    attrs
    |> Mud.new()
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
    |> Mud.update(attrs)
    |> Repo.update()
  end

  @doc """
  Updates a mud.

  ## Examples

      iex> update_mud(42, %{field: new_value})
      {:ok, %Mud{}}

      iex> update_mud(42, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

      iex> update_mud(24, %{field: new_value})
      {:error, :not_found}

  """
  def update_mud(mud_id, attrs) do
    case get_mud(mud_id) do
      {:ok, mud} ->
        update_mud(mud, attrs)

      error ->
        error
    end
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
  Returns the list of characters.

  ## Examples

      iex> list_characters()
      {:ok, [%Character{}, ...]}

  """
  @spec list_characters :: {:ok, [Character.t()]}
  def list_characters do
    {:ok, Repo.all(Character)}
  end

  @doc """
  Gets a single character.

  Raises `Ecto.NoResultsError` if the Character does not exist.

  ## Examples

      iex> get_character!("good uuid")
      %Character{}

      iex> get_character!("bad uuid")
      ** (Ecto.NoResultsError)

  """
  @spec get_character_by_id!(String.t()) :: Character.t()
  def get_character_by_id!(id), do: Repo.get!(Character, id)

  @doc """
  Gets a single character.

  ## Examples

      iex> get_character("good uuid")
      {:ok, %Character{}}

      iex> get_character("bad uuid")
      {:error, :not_found}

  """
  @spec get_character_by_id(String.t()) :: {:ok, Character.t()} | {:error, :not_found}
  def get_character_by_id(id) do
    case Repo.get(Character, id) do
      nil ->
        {:error, :not_found}

      character ->
        {:ok, character}
    end
  end

  @doc """
  Gets a single character.

  Raises `Ecto.NoResultsError` if the Character does not exist.

  ## Examples

      iex> get_character!("good slug")
      %Character{}

      iex> get_character!("bad slug")
      ** (Ecto.NoResultsError)

  """
  @spec get_character_by_slug!(String.t()) :: Character.t()
  def get_character_by_slug!(slug), do: Repo.get_by!(Character, slug: slug)

  @doc """
  Gets a single character.

  ## Examples

      iex> get_character("good slug")
      {:ok, %Character{}}

      iex> get_character("bad slug")
      {:error, :not_found}

  """
  @spec get_character_by_slug(String.t()) :: {:ok, Character.t()} | {:error, :not_found}
  def get_character_by_slug(slug) do
    case Repo.get_by(Character, slug: slug) do
      nil ->
        {:error, :not_found}

      character ->
        {:ok, character}
    end
  end

  @doc """
  Creates a character.

  ## Examples

      iex> create_character(%{field: value})
      {:ok, %Character{}}

      iex> create_character(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec create_character(map) :: {:ok, Character.t()} | {:error, Ecto.Changeset.t()}
  def create_character(attrs \\ %{}) do
    attrs
    |> Character.new()
    |> Repo.insert()
  end

  @doc """
  Updates a character.

  ## Examples

      iex> update_character(character, %{field: new_value})
      {:ok, %Character{}}

      iex> update_character(character, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec update_character(Character.t(), map) ::
          {:ok, Character.t()} | {:error, Ecto.Changeset.t()}
  def update_character(%Character{} = character, attrs) do
    character
    |> Character.update(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Character.

  ## Examples

      iex> delete_character(character)
      {:ok, %Character{}}

      iex> delete_character(character)
      {:error, %Ecto.Changeset{}}

  """
  @spec delete_character(Character.t()) :: {:ok, Character.t()} | {:error, Ecto.Changeset.t()}
  def delete_character(%Character{} = character) do
    Repo.delete(character)
  end

  @doc """
  List all of the Characters that belong to a single Player.

  ## Examples

      iex> list_player_characters(42)
      {:ok, [%Character{}]}

      iex> list_player_characters(43)
      {:ok, []}
  """
  @spec list_player_characters(String.t()) :: {:ok, [Character.t()]}
  def list_player_characters(player_id) when is_binary(player_id) do
    {:ok,
     Repo.all(
       from(
         character in Character,
         join: player in Player,
         where: player.id == character.player_id and character.player_id == ^player_id
       )
     )}
  end
end

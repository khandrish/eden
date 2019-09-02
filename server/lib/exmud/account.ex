defmodule Exmud.Account do
  @moduledoc """
  The Account context.
  """

  import Ecto.Query, warn: false
  alias Exmud.Account.Player
  alias Exmud.Repo
  import OK, only: [success: 1, failure: 1]
  require Logger

  @topic inspect(__MODULE__)

  @doc """
  Subscribe to the PubSub topic for all Account events.
  """
  @spec subscribe :: {:ok, :subscribed}
  def subscribe do
    :ok = Phoenix.PubSub.subscribe(Exmud.PubSub, @topic)
    {:ok, :subscribed}
  end

  @doc """
  Subscribe to the PubSub topic for all Account events related to a single player.
  """
  @spec subscribe(integer()) :: {:ok, :subscribed}
  def subscribe(player_id) do
    :ok = Phoenix.PubSub.subscribe(Exmud.PubSub, @topic <> ":#{player_id}")
    {:ok, :subscribed}
  end

  @doc """
  Send out a login email with a short lived token.
  """
  def send_login_email(email_address) do
    case lookup_player_by_email(email_address) do
      success(player_id) ->
        login_token = Phoenix.Token.sign(ExmudWeb.Endpoint, "player login", player_id)
        from_email_address = Application.get_env(:exmud, :no_reply_email_address)

        Exmud.Account.Email.login_email(email_address, from_email_address, login_token)
        |> Exmud.Mailer.deliver_later()

        {:ok, :email_sent}

      failure(:not_found) ->
        {:error, :not_found}
    end
  end

  @login_token_ttl Application.get_env(:exmud, :login_token_ttl, 900)

  @doc """
  Verify a login token and, if valid, return the Player it points to.
  """
  def verify_login_token(token) do
    with success(player_id) <-
           Phoenix.Token.verify(ExmudWeb.Endpoint, "player login", token,
             max_age: @login_token_ttl
           ),
         player = %Exmud.Account.Player{} <- Exmud.Repo.get(Exmud.Account.Player, player_id) do
      {:ok, player}
    else
      nil ->
        {:error, :invalid}

      failure(error) ->
        {:error, error}
    end
  end

  @doc """
  Given params including nickname and email, create a player and their profile.

  Will return a profile changeset if there was an error.
  """
  def signup(params) do
    Ecto.Multi.new()
    |> Ecto.Multi.insert(:player, Exmud.Account.Player.new())
    |> Ecto.Multi.insert(:profile, fn %{player: %Exmud.Account.Player{id: player_id}} ->
      Exmud.Account.Profile.new(Map.put(params, "player_id", player_id))
    end)
    |> Exmud.Repo.transaction()
    |> case do
      {:ok, %{player: player}} ->
        {:ok, player}
        |> notify_subscribers([:player, :created])

        {:ok, player.id}

      {:error, :profile, changeset, _} ->
        {:error, changeset}
    end
  end

  @doc """
  Returns the list of players.
  ## Examples
      iex> list_players()
      [%Player{}, ...]
  """
  def list_players() do
    Repo.all(
      from player in Player,
        order_by: [asc: player.id]
    )
  end

  @doc """
  Returns the list of players in a paginated manner.
  ## Examples
      iex> list_players(1, 100)
      [%Player{}, ...]
  """
  def list_players(current_page, per_page) do
    Repo.all(
      from player in Player,
        order_by: [asc: player.id],
        offset: ^((current_page - 1) * per_page),
        limit: ^per_page
    )
  end

  @doc """
  Gets a single player.

  ## Examples

      iex> get_player(123)
      %Player{}

      iex> get_player(456)
      nil

  """
  def get_player(id), do: Repo.get(Player, id)

  @doc """
  Gets a single player.

  Raises `Ecto.NoResultsError` if the Player does not exist.

  ## Examples

      iex> get_player!(123)
      %Player{}

      iex> get_player!(456)
      ** (Ecto.NoResultsError)

  """
  def get_player!(id), do: Repo.get!(Player, id)

  @doc """
  Creates a player.

  ## Examples

      iex> create_player(%{field: value})
      {:ok, %Player{}}

      iex> create_player(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_player() do
    Player.new()
    |> Repo.insert()
    |> notify_subscribers([:player, :created])
  end

  def lookup_player_by_email(email) do
    Repo.one(
      from player in Player,
        join: profile in Exmud.Account.Profile,
        where: player.id == profile.player_id and profile.email == ^email,
        select: player.id
    )
    |> case do
      nil ->
        {:error, :not_found}

      player_id ->
        {:ok, player_id}
    end
  end

  @doc """
  Deletes a Player.

  ## Examples

      iex> delete_player(player)
      {:ok, %Player{}}

      iex> delete_player(player)
      {:error, %Ecto.Changeset{}}

  """
  def delete_player(%Player{} = player) do
    Repo.delete(player)
    |> notify_subscribers([:player, :deleted])
  end

  alias Exmud.Account.Profile

  @doc """
  Returns the list of profiles.

  ## Examples

      iex> list_profiles()
      [%Profile{}, ...]

  """
  def list_profiles do
    Repo.all(Profile)
  end

  @doc """
  Gets a single profile.

  Raises `Ecto.NoResultsError` if the Profile does not exist.

  ## Examples

      iex> get_profile!(123)
      %Profile{}

      iex> get_profile!(456)
      ** (Ecto.NoResultsError)

  """
  def get_profile!(id), do: Repo.get!(Profile, id)

  @doc """
  Creates a profile.

  ## Examples

      iex> create_profile(%{field: value})
      {:ok, %Profile{}}

      iex> create_profile(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_profile(attrs \\ %{}) do
    Profile.new(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a profile.

  ## Examples

      iex> update_profile(profile, %{field: new_value})
      {:ok, %Profile{}}

      iex> update_profile(profile, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_profile(%Profile{} = profile, attrs) do
    profile
    |> Profile.update(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Profile.

  ## Examples

      iex> delete_profile(profile)
      {:ok, %Profile{}}

      iex> delete_profile(profile)
      {:error, %Ecto.Changeset{}}

  """
  def delete_profile(%Profile{} = profile) do
    Repo.delete(profile)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking profile changes.

  ## Examples

      iex> change_profile(profile)
      %Ecto.Changeset{source: %Profile{}}

  """
  def change_profile(%Profile{} = profile) do
    Profile.changeset(profile)
  end

  #
  # Private functions
  #

  defp notify_subscribers(result, event, global_only \\ false)

  defp notify_subscribers({:ok, result}, event, global_only) do
    Phoenix.PubSub.broadcast(Exmud.PubSub, @topic, {__MODULE__, event, result})

    if not global_only do
      Phoenix.PubSub.broadcast(
        Exmud.PubSub,
        @topic <> ":#{result.id}",
        {__MODULE__, event, result}
      )
    end

    {:ok, result}
  end

  defp notify_subscribers({:error, reason}, _event, _global_only), do: {:error, reason}
end

defmodule Exmud.Account do
  @moduledoc """
  The Account context.
  """

  import Ecto.Query, warn: false
  alias Exmud.Account.Player
  alias Exmud.Account.Constants.{PlayerStatus}
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

  ## Examples

      iex> verify_login_token(token)
      {:ok, %Player{}}

      iex> verify_login_token(bad_arams)
      {:error, :invalid}
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
  Facilitates the creation of a Player via direct registration with an Email and Nickname.

  While the Player must supply the Email address and Nickname on registration, these actually belong to the Profile
  behind the scenes rather than the Player object directly. This function handles the creation and linking of the
  Player and Profile objects as well as the instantion of anything else required for an Account to work correctly,
  such as Player Roles etc...

  Will return a changeset if there was an error.

  ## Examples

      iex> register_player(params)
      {:ok, %Player{}}

      iex> register_player(bad_arams)
      {:error, %Ecto.Changeset{}}
  """
  def register_player(params) do
    Ecto.Multi.new()
    |> Ecto.Multi.insert(:player, Exmud.Account.Player.new(%{status: PlayerStatus.registered()}))
    |> Ecto.Multi.insert(:profile, fn %{player: player} ->
      Ecto.build_assoc(player, :profile, params)
      |> Exmud.Account.Profile.validate()
    end)
    |> Exmud.Repo.transaction()
    |> case do
      {:ok, %{player: player, profile: profile}} ->
        {:ok, player}
        |> notify_subscribers([:player, :created])

        IO.inspect(player)

        {:ok, %{player | profile: profile}}

      {:error, :profile, changeset, _} ->
        failure(changeset)
    end
  end

  @doc """
  Returns the list of players in a paginated manner, wrapped in a success tuple.
  ## Examples
      iex> list_players(1, 100)
      {:ok, [%Player{}, ...]}
  """
  def list_players(page, page_size) do
    success(
      Repo.all(
        from player in Player,
          order_by: [asc: player.inserted_at],
          offset: ^((page - 1) * page_size),
          limit: ^page_size,
          preload: :profile
      )
    )
  end

  @doc """
  Gets a single player.

  ## Examples

      iex> get_player(123)
      {:ok, %Player{}}

      iex> get_player(456)
      {:error, nil}

  """
  def get_player(id) do
    case Repo.get(Player, id) do
      nil ->
        failure(:not_found)

      player ->
        success(player)
    end
  end

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
  def create_player(params) do
    Player.new(params)
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

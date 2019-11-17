defmodule Exmud.Account do
  @moduledoc """
  The API for the Account context.

  The constants or schemas can be used for pattern matching, but all Account functionality can be found here.

  ## Overview
  All functionality that is intrinsically tied to the existence of a Player can be found here. Something like Billing,
  while providing the ability for a Player to subscribe to a recurring payment, can be used anonymously by someone via
  the Store and so is in its own context.
  """

  import Ecto.Query, warn: false

  alias Exmud.Account
  alias Exmud.Account.Player
  alias Exmud.Repo

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
  Subscribe to the PubSub topic for all Account events related to a single Player.
  """
  @spec subscribe(integer()) :: {:ok, :subscribed}
  def subscribe(player_id) when is_integer(player_id) do
    :ok = Phoenix.PubSub.subscribe(Exmud.PubSub, @topic <> ":#{player_id}")
    {:ok, :subscribed}
  end

  @login_token_ttl Application.get_env(:exmud, :login_token_ttl)
  @signup_player_token_ttl Application.get_env(:exmud, :create_player_token_ttl)
  @from_email_address Application.get_env(:exmud, :no_reply_email_address)

  @doc """
  Send a login or welcome email out based on whether or not a Player exists that uses the provided email.

  New Players will be directed to the TOS page. Returning Players will be directed to the Player Dashboard.
  """
  def authenticate_via_email(email_address) do
    auth_token = UUID.uuid4() |> String.replace("-", "")

    case lookup_player_by_auth_email(email_address) do
      {:ok, player_id} ->
        redis_set_player_auth_token(auth_token, "login", player_id, @login_token_ttl)

        Exmud.Account.Emails.login_email(email_address, @from_email_address, auth_token)
        |> Exmud.Mailer.deliver_later()

        {:ok, :player_found}

      {:error, :not_found} ->
        signup_new_player(email_address, auth_token)
    end
  end

  defp signup_new_player(email_address, auth_token) do
    email_hash = hash_email(email_address)
    encrypted_email = Exmud.Vault.encrypt!(email_address)

    player_changeset = Player.new(%{status: Account.Constants.PlayerStatus.pending()})

    Ecto.Multi.new()
    |> Ecto.Multi.insert(:player, player_changeset)
    |> UberMulti.run(
      :build_auth,
      [:player, :auth_email, %{email: encrypted_email, hash: email_hash}],
      &Ecto.build_assoc/3,
      true
    )
    |> UberMulti.run(:insert_auth, [:build_auth], &Repo.insert/1)
    |> Repo.transaction()
    |> case do
      {:ok, %{player: player}} ->
        redis_set_player_auth_token(
          auth_token,
          "signup",
          player.id,
          @signup_player_token_ttl
        )

        Exmud.Account.Emails.welcome_email(email_address, @from_email_address, auth_token)
        |> Exmud.Mailer.deliver_later()

        {:ok, :player_created}

      _error ->
        {:error, :player_not_created}
    end
  end

  defp redis_set_player_auth_token(auth_token, type, player_id, expiry) do
    Redix.command(:redix, [
      "SET",
      "player-auth-token:#{auth_token}",
      "#{type}:#{player_id}",
      "EX",
      expiry
    ])
  end

  @doc """
  Verify a login token and, if valid, return the Player it points to.

  ## Examples

      iex> validate_auth_token(token)
      {:ok, %Player{}}

      iex> validate_auth_token(bad_token)
      {:error, :invalid}
  """
  def validate_auth_token(auth_token) do
    case Redix.command!(:redix, ["GET", "player-auth-token:#{auth_token}"]) do
      nil ->
        {:error, :invalid}

      string ->
        Redix.command!(:redix, ["DEL", "player-auth-token:#{auth_token}"])

        [type, player_id] = String.split(string, ":")
        player_query = from(player in Account.Player, where: player.id == ^player_id)

        case type do
          "signup" ->
            from(auth_email in Account.AuthEmail, where: auth_email.player_id == ^player_id)
            |> Exmud.Repo.update_all(set: [email_validated: true])

            Exmud.Repo.update_all(player_query,
              set: [status: Account.Constants.PlayerStatus.created()]
            )

            player = Exmud.Repo.one!(player_query)

            {:ok, player}

          "login" ->
            player = Exmud.Repo.one!(player_query)

            {:ok, player}
        end
    end
  end

  @doc """
  Facilitates the creation of a Player with an Email and Nickname.

  While the Player must supply the Email address and Nickname, these actually belong to the Profile rather than the
  Player. This function handles the creation and linking of the Player and Profile as well as the instantion of
  anything else required for an Account to work correctly, such as Roles etc...

  Will return a changeset if there was an error.

  ## Examples

      iex> create_player(params)
      {:ok, %Player{}}

      iex> create_player(bad_params)
      {:error, %Ecto.Changeset{}}
  """
  def create_player(params) do
    params
    |> Player.new()
    |> Repo.insert()
    |> notify_subscribers([:player, :created])
  end

  @doc """
  Returns the list of players in a paginated manner, wrapped in a success tuple.

  ## Examples
      iex> list_players(1, 100)
      {:ok, [%Player{}, ...]}
  """
  def list_players(page, page_size) do
    {:ok,
     Repo.all(
       from player in Player,
         order_by: [asc: player.inserted_at],
         offset: ^((page - 1) * page_size),
         limit: ^page_size,
         preload: :profile
     )}
  end

  @doc """
  Gets a single player.

  ## Examples

      iex> get_player(123)
      {:ok, %Player{}}

      iex> get_player(456)
      {:error, :not_found}

  """
  def get_player(id) do
    case Repo.get(Player, id) do
      nil ->
        {:error, :not_found}

      player ->
        {:ok, player}
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

  @doc """
  Updates a player.

  ## Examples

      iex> update_player(player, %{field: new_value})
      {:ok, %Player{}}

      iex> update_player(player, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_player(%Player{} = player, attrs) do
    player
    |> Player.update(attrs)
    |> Repo.update()
    |> notify_subscribers([:player, :updated])
  end

  alias Exmud.Account.Profile

  @doc """
  Returns the list of profiles.

  ## Examples

      iex> list_profiles()
      {:ok, [%Profile{}, ...]}

  """
  def list_profiles do
    Profile
    |> Repo.all()
    |> (&{:ok, &1}).()
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
    |> notify_subscribers([:profile, :created])
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
    |> notify_subscribers([:profile, :updated])
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
    |> notify_subscribers([:profile, :deleted])
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

  defp hash_email(email_address), do: :crypto.hash(:sha, email_address) |> String.slice(0..4)

  defp lookup_player_by_auth_email(email) do
    email_hash = hash_email(email)

    Repo.all(
      from player in Player,
        join: auth_email in Exmud.Account.AuthEmail,
        where: player.id == auth_email.player_id and auth_email.hash == ^email_hash,
        select: %{player: player.id, email: auth_email.email}
    )
    |> Enum.filter(fn %{email: encrypted_email} ->
      Exmud.Vault.decrypt!(encrypted_email) === email
    end)
    |> case do
      [] ->
        {:error, :not_found}

      [%{player: player_id}] ->
        {:ok, player_id}
    end
  end

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

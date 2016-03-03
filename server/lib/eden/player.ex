defmodule Eden.Player do
  @moduledoc """
  Provides the interface for working with Players. When working with Player
  objects they should be considered opaque and manipulation should be handled
  by this module.

  If you don't care about the inner workings you can stop reading here.

  There are two broad classes of API functions, those which interact with the
  database and those which instead work with the opaque Player object.

  The latter group includes the get/2, set/2, and set/3 functions. Everything
  else interacts with the database directly as there is currently no general
  cache layer. Depending on the results of future testing this may change.



  ## Examples

      iex> player_id = Phoenix.Token.verify(endpoint, "player", token)
      iex> {:ok, player} = Player.read(player_id)
      iex> {:ok, player} = Player.set(player, "name", "John Doe")
      iex> {:ok, _} = Player.save(player)

  """

  alias Eden.Endpoint
  alias Eden.Mailer
  alias Eden.PlayerLock, as: PL
  alias Eden.PlayerToken, as: PT
  alias Eden.Repo
  alias Eden.Schema.Player, as: PlayerSchema
  alias Eden.Time, as: ET
  import Comeonin.Bcrypt, only: [hashpwsalt: 1]
  import Ecto
  import Ecto.Changeset
  import Ecto.Query, only: [from: 2]
  require Logger
  use Pipe


  #
  #  Attributes
  #

  @verify_email_salt "email verification token"
  @password_reset_salt "password reset token"

  @optional_params ~w(email email_verified failed_login_attempts last_login login name password)
  @required_params ~w(login name email password)

  #
  # CRUD operations
  #

  def create(params) do
    {status, player} = result =
      %Eden.Schema.Player{}
      |> cast(params, @required_params, @optional_params)
      |> validate_params
      |> handle_updates
      |> Repo.insert

    if status == :ok, do: Logger.info "Player #{player.id} created"

    result
  end

  def delete(id) do
    case Repo.get(PlayerSchema, id) do
      nil ->
        Logger.warn "Player #{id} not found in database when attempting to delete"
        {:error, :player_not_found}
      player ->
        case Repo.delete(player) do
          {:ok, player} ->
            Logger.info "Player #{player.id} has been deleted"
            {:ok, player}
          {:error, player} ->
            Logger.warn "Unable to delete player #{id}"
            {:error, player}
        end
    end
  end

  def read(id) do
    case Repo.get(PlayerSchema, id) do
      nil ->
        Logger.warn "Player #{id} not found in database when attempting a read"
        {:error, :player_not_found}
      player ->
        {:ok, player}
    end
  end

  def update(player) do
    case Repo.update player do
      {:ok, _} = result ->
        result
      {:error, _} = result ->
        Logger.warn "Unable to save player #{player.id} when updating"
        result
    end
  end


  #
  # Getters and setters for `opaque` data structure
  #

  def get(player, key, default \\ nil) do
    get_field(player, key, default)
  end

  def set(player, key, value) do
    set(player, Map.new([{key, value}]))
  end

  def set(player, params) do
    changeset = cast(player, params, [], @optional_params)
    |> validate_params

    if changeset.valid? do
      changeset = handle_updates(changeset)
      {:ok, changeset}
    else
      {:error, changeset}
    end
  end


  #
  # Password related operations
  #

  def start_password_reset(search_text) do
    if String.contains?(search_text, "@") do
      send_token(Repo.get_by(PlayerSchema, email: search_text))
    else
      send_token(Repo.get_by(PlayerSchema, login: search_text))
    end
  end

  defp send_token(nil) do
    {:error, :player_not_found}
  end

  defp send_token(player) do
    token = Phoenix.Token.sign(Endpoint, @password_reset_salt, player.id)

    {status, player_token} =
      PT.create(player, %{type: "password reset", token: token})

    if status == :ok do
      Mailer.send_password_reset_email(player.email, token)
      player = Repo.preload(player, :player_tokens)
      {:ok, player}
    else
      {:error, :unable_to_create_token}
    end
  end

  def finish_password_reset(token, password) do
    {status, player} = result =
      pipe_matching x, {:ok, x},
        Phoenix.Token.verify(Endpoint, @password_reset_salt, token, max_age: password_reset_token_ttl)
        |> read
        |> set(%{password: password})
        |> update

    if status == :ok do
      PT.delete_all(player, "password reset")
      result
    else
      {:error, :password_reset_failed}
    end
  end

  defp password_reset_token_ttl do
    Application.get_env(:eden, :password_reset_token_ttl)
  end


  #
  # Authentication and related operations
  #

  def authenticate(login, password) do
    query = from p in PlayerSchema,
              where: p.login == ^login,
              select: p,
              preload: [:player_locks]

    case Repo.one(query) do
      player ->
        if PL.any_active_locks?("login", player.player_locks) == false do
          {authenticated, player} = if Comeonin.Bcrypt.checkpw(password, player.hash) do
            {true, change(player, %{failed_login_attempts: 0, last_login: ET.now_utc})}
          else
            player =
              if player.failed_login_attempts > failed_logins_allowed do
                disable_login(player, "Too many failed login attempts.", failed_login_lockout_period)
                change(player, %{failed_login_attempts: 0})
              else
                change(player, %{failed_login_attempts: player.failed_login_attempts + 1})
              end

            {false, player}
          end

          {status, player} = result = Repo.update player

          cond do
            authenticated == true and status == :ok ->
              Logger.info "Player #{player.id} authenticated"
              result
            status == :ok ->
              {:error, :invalid_password}
            true ->
              Logger.warn "Unable to update player #{player.id} when authenticating"
              result
          end
        else
          {:error, :active_login_lock}
        end
      nil ->
        {:error, :player_not_found}
    end
  end

  def disable_login(player, reason, time) do
    params = %{
      :type => "login",
      :reason => reason,
      :expiry => ET.timestamp_after_utc(time)
    }
    
    case PL.create(player, params) do
      {:ok, _} ->
        {:ok, player}
      result ->
        result
    end
  end

  defp failed_logins_allowed do
    Application.get_env(:eden, :failed_logins_allowed)
  end

  defp failed_login_lockout_period do
    Application.get_env(:eden, :failed_login_lockout_period)
  end

  
  #
  # Email related operations
  #  

  def start_email_verification(player) do
    token = Phoenix.Token.sign(Endpoint, @verify_email_salt, player.id)

    {status, player_token} =
      PT.create(player, %{type: "verify email", token: token})

    if status == :ok do
      Mailer.send_email_verification_email(player.email, token)
      player = Repo.preload(player, :player_tokens)
      {:ok, player}
    else
      {:error, :unable_to_create_token}
    end
  end

  def finish_email_verification(token) do
    {status, player} = result =
      pipe_matching x, {:ok, x},
        Phoenix.Token.verify(Endpoint, @verify_email_salt, token, max_age: email_verification_token_ttl)
        |> read
        |> set(:email_verified, true)
        |> update

    if status == :ok do
      PT.delete_all(player, "verify email")
      result
    else
      {:error, :email_verification_failed}
    end
  end

  defp email_verification_token_ttl do
    Application.get_env(:eden, :email_verification_token_ttl)
  end

  #
  # Validation and update logic
  #

  defp validate_params(changeset) do
    changeset
    |> validate_length(:login, min: 12, max: 255)
    |> unique_constraint(:login)
    |> validate_length(:password, min: 12, max: 50)
    |> validate_format(:email, ~r/@/)
    |> validate_length(:name, min: 2, max: 50)
    |> unique_constraint(:name)
    |> unique_constraint(:id)
  end

  defp handle_updates(changeset) do
    changeset
    |> handle_password_update
  end

  defp handle_password_update(changeset) do
    case fetch_change(changeset, :password) do
      {:ok, password} -> put_change(changeset, :hash, hashpwsalt(password))
      :error -> changeset
    end
  end
end
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

  alias Eden.Repo
  alias Eden.Schema.Player, as: PlayerSchema
  import Comeonin.Bcrypt, only: [hashpwsalt: 1]
  import Ecto.Changeset
  require Logger
  use Pipe

  #
  #  Attributes
  #

  @verify_email_salt "email verification token"
  @password_reset_salt "password reset token"

  @optional_params ~w(email email_verified failed_login_attempts last_login last_name_change login name password)
  @required_params ~w(login name email password)

  #
  # API
  #

  def authenticate(login, password) do
    Logger.debug "Authenticating player with login: #{login}"

    case Repo.get_by(PlayerSchema, login: login) do
      nil ->
        Logger.debug "Player not found"
        {:error, :player_not_found}
      player ->
        Logger.debug "Player found"
        cond do
          Comeonin.Bcrypt.checkpw(password, player.hash) ->
            #player
            #|> Player.set("failed_login_attempts")
            player = Repo.update!(%{player | failed_login_attempts: 0, last_login: Calendar.DateTime.now_utc})
            Logger.info "#Player {player.id} has been authenticated"
            {:ok, player}
          true ->
            Logger.debug "Password did not match"
            {:error, :invalid_password}
        end
    end
  end

  def create(params) do
    Logger.debug "Creating new player"
    
    changeset = %Eden.Schema.Player{}
    |> cast(params, @required_params, @optional_params)
    |> validate_params

    Logger.debug "Changeset valid?: #{inspect changeset.valid?}"

    if changeset.valid? do
      player = changeset
      |> handle_updates
      |> Repo.insert!

      Logger.info "Player #{player.id} has been created"

      {:ok, player}
    else
      Logger.debug "Player not created due to invalid params"
      {:error, changeset}
    end
  end

  def delete(id) do
    Logger.debug "Deleting player: #{id}"

    case Repo.get(PlayerSchema, id) do
      nil ->
        Logger.warn "Player #{id} not found in database when attempting a delete"
        {:error, :player_not_found}
      player ->
        Logger.debug "Player found"
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

  def get(player, key, default \\ nil) do
    Logger.debug "Getting #{key} from player #{player.id} with default of #{default}"
    
    value = get_field(player, key, default)
    
    Logger.debug "Returning value: #{value}"
    value
  end

  def read(id) do
    Logger.debug "Reading player from database: #{id}"

    case Repo.get(PlayerSchema, id) do
      nil ->
        Logger.warn "Player #{id} not found in database when attempting a read"
        {:error, "Player not found"}
      player ->
        Logger.debug "Player #{id} read from database"
        {:ok, player}
    end
  end

  def reset_password(token, password) do
    Logger.debug "Resetting password using token: #{token}"
    
    case Phoenix.Token.verify(Eden.Endpoint, @password_reset_salt, token, max_age: password_reset_token_ttl) do
      {:ok, player_id} ->
        Logger.debug "Token verified"
        case read(player_id) do
          {:ok, player} ->
            # TODO: Check token
            case set(player, %{password: password}) do
              {:ok, player} ->
                Logger.debug "New password is valid"
                case update player do
                  {:ok, player} = result ->
                    Logger.info "Password reset for player #{player.id}"
                    result
                  result ->
                    Logger.warn "Unable to save player #{player.id} when resetting password"
                    result
                end
              {:error, _} ->
                Logger.debug "New password is invalid"
                {:error, :invalid_password}
            end
          {:error, _} ->
            {:error, :player_not_found}
        end
      {:error, _} ->
        Logger.debug "Invalid token"
        {:error, :invalid_token}
    end
  end

  def send_password_reset_email(search) do
    Logger.debug "Sending password reset email to player found by using search term: #{search}"

    player = if String.contains?(search, "@") do
      Logger.debug "Searching for player by email"
      Repo.get_by(PlayerSchema, email: search)
    else
      Logger.debug "Searching for player by login"
      Repo.get_by(PlayerSchema, login: search)
    end

    if player == nil do
      Logger.debug "Player not found"
      {:error, :player_not_found}
    else
      Logger.debug "Player found"
      # TODO: Save token and fix mail logic
      # token = Phoenix.Token.sign(conn, @password_reset_salt, player.id)
      # Mailer.send_password_reset_email(player)
      {:ok, player}
    end
  end

  def set(player, key, value) do
    set(player, Map.new([{key, value}]))
  end

  def set(player, params) do
    Logger.debug "Setting value(s) on player object #{inspect params}"
    changeset = cast(player, params, [], @optional_params)
    |> validate_params

    if changeset.valid? do
      changeset = handle_updates(changeset)
      Logger.debug "Changeset valid?: #{changeset.valid?}"
      {:ok, changeset}
    else
      Logger.debug "Changeset invalid, bad params"
      {:error, changeset}
    end
  end

  def update(player) do
    Logger.debug "Updating player #{player.id}"

    case Repo.update player do
      {:ok, _} = result ->
        Logger.debug "Player updated"
        result
      {:error, _} = result ->
        Logger.warn "Unable to save player #{player.id} when updating"
        result
    end
  end

  def verify_email(token) do
    Logger.debug "Verifying email with token: #{token}"

    case Phoenix.Token.verify(Eden.Endpoint, @verify_email_salt, token, max_age: email_verification_token_ttl) do
      {:ok, player_id} ->
        Logger.debug "Token verified, getting player by id: #{player_id}"
        case Repo.get(PlayerSchema, player_id) do
          nil ->
            Logger.debug "Player not found"
            {:error, :player_not_found}
          player ->
            Logger.debug "Player found"
            # TODO: check token from returned player and either save as below or return error
            result = pipe_matching x, {:ok, x}, player
            |> Player.set(:email_verified, true)
            |> Player.update

            # TODO: Delete token
            result
        end
      {:error, _} ->
        Logger.debug "Invalid token"
        {:error, :invalid_token}
    end
  end

  #
  # Private Functions
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

  # Token TTL's

  defp email_verification_token_ttl do
    Application.get_env(:eden, :email_verification_token_ttl)
  end

  defp password_reset_token_ttl do
    Application.get_env(:eden, :password_reset_token_ttl)
  end

  # Update logic

  defp handle_updates(changeset) do
    changeset
    |> handle_email_update
    |> handle_name_update
    |> handle_password_update
  end

  defp handle_email_update(changeset) do
    if fetch_change(changeset, :email) != :error do
      # TODO: Save token and update email logic
      # token = Phoenix.Token.sign(:eden, @verify_email_salt, player.id)
      # Mailer.send_email_validation_email(player)
      put_change(changeset, :email_verified, false)
    else
      changeset
    end
  end

  defp handle_name_update(changeset) do
    if fetch_change(changeset, :name) != :error do
      put_change(changeset, :last_name_change, Calendar.DateTime.now_utc)
    else
      changeset
    end
  end

  defp handle_password_update(changeset) do
    case fetch_change(changeset, :password) do
      {:ok, password} -> put_change(changeset, :hash, hashpwsalt(password))
      :error -> changeset
    end
  end
end

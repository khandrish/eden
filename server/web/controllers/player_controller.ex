defmodule Eden.PlayerController do
  use Eden.Web, :controller
  import Ecto.Changeset
  import Comeonin.Bcrypt, only: [hashpwsalt: 1]

  alias Eden.Player
  alias Eden.Mailer
  alias Eden.Repo
  alias Eden.Plug.FilterParams
  alias Eden.Plug.ScrubExistingParams
  alias Eden.Plug.EnsureSomeParams
  alias Eden.Plug.EnsureAllParams
  alias Eden.Plug.EnsurePopulatedParams
  alias Eden.Plug.Authenticated
  alias Eden.Plug.HasAllPermissions

  # Create plugs
  plug FilterParams, ~w(login name email password password_confirmation) when action in [:create]
  plug EnsureAllParams, ~w(login name email password password_confirmation) when action in [:create]
  plug ScrubExistingParams, ~w(login name email password password_confirmation) when action in [:create]
  plug EnsurePopulatedParams, ~w(login name email password password_confirmation) when action in [:create]

  # Update plugs
  plug Authenticated when action in [:update]
  plug HasAllPermissions, ~w(self) when action in [:update]
  plug FilterParams, ~w(id login name email password password_confirmation) when action in [:update]
  plug EnsureAllParams, ~w(id) when action in [:update]
  plug EnsureSomeParams, ~w(login name email password password_confirmation) when action in [:update]
  plug ScrubExistingParams, ~w(id login name email password password_confirmation) when action in [:update]
  plug EnsurePopulatedParams, ~w(id login name email password password_confirmation) when action in [:update]

  # Show plugs
  plug FilterParams, ~w(id) when action in [:show]
  plug EnsureAllParams, ~w(id) when action in [:show]
  plug ScrubExistingParams, ~w(id) when action in [:show]
  plug EnsurePopulatedParams, ~w(id) when action in [:show]

  # Verify Email plugs
  plug FilterParams, ~w(token) when action in [:verify_email]
  plug EnsureAllParams, ~w(token) when action in [:verify_email]
  plug ScrubExistingParams, ~w(token) when action in [:verify_email]
  plug EnsurePopulatedParams, ~w(id) when action in [:verify_email]

  # Send Password Reset Email plugs
  plug FilterParams, ~w(search) when action in [:send_password_reset_email]
  plug EnsureAllParams, ~w(search) when action in [:send_password_reset_email]
  plug ScrubExistingParams, ~w(search) when action in [:send_password_reset_email]
  plug EnsurePopulatedParams, ~w(search) when action in [:send_password_reset_email]

  # Delete Plugs
  plug Authenticated when action in [:delete]
  plug HasAllPermissions, ~w(self) when action in [:delete]
  plug EnsureAllParams, ~w(id) when action in [:delete]
  plug ScrubExistingParams, ~w(id) when action in [:delete]
  plug EnsurePopulatedParams, ~w(id) when action in [:delete]

  # Login plugs
  plug FilterParams, ~w(login password) when action in [:login]
  plug EnsureAllParams, ~w(login password) when action in [:login]
  plug ScrubExistingParams, ~w(login password) when action in [:login]
  plug EnsurePopulatedParams, ~w(login password) when action in [:login]
  plug EnsurePopulatedParams, ~w(login password) when action in [:login]

  # Logout plugs
  plug Authenticated when action in [:logout]
  plug FilterParams, ~w(id) when action in [:logout]
  plug EnsureAllParams, ~w(id) when action in [:logout]
  plug ScrubExistingParams, ~w(id) when action in [:logout]
  plug EnsurePopulatedParams, ~w(id) when action in [:logout]
  plug HasAllPermissions, ~w(self) when action in [:logout]

  @verify_email_salt "validate email salt"
  @password_reset_salt "reset password salt"

  def index(conn, _params) do
    # TODO: return different data based on the permissions available to the session
    players = Repo.all(Player)
    render(conn, "index.json", players: players)
  end

  def create(conn, params) do
    changeset = Player.changeset(:create, %Player{}, params)

    if changeset.valid? do
      insert_result = changeset
      |> generate_password_hash
      |> Repo.insert(changeset)

      case insert_result do
        {:ok, player} ->
          token = Phoenix.Token.sign(conn, @verify_email_salt, player.id)
          player = Repo.update!(%{player | email_validation_token: token})
          Mailer.send_email_validation_email(player)
          conn
          |> put_flash(:info, "Verification email sent to provided email address.")
          |> assign(:email_verification_token, token)
          |> put_status(:created)
          |> render("show.json", player: player)
        {:error, changeset} ->
          conn
          |> put_status(:unprocessable_entity)
          |> render(Eden.ChangesetView, "error.json", changeset: changeset)
      end
    else
      conn
      |> put_status(:unprocessable_entity)
      |> render(Eden.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    # TODO: return different data based on the permissions available to the session
    case Repo.get(Player, id) do
      nil ->
        conn |> send_resp(:not_found, "")
      player ->
        render conn, "show.json", player: player
    end
  end

  def update(conn, params) do
    case Repo.get(Player, Map.get(params, "id")) do
      nil ->
        conn |> send_resp(:not_found, "")
      player ->
        changeset = Player.changeset(:update, player, params)
        if changeset.valid? do
          if Map.has_key?(params, :email) and params.email != nil do
            token = Phoenix.Token.sign(conn, @verify_email_salt, player.id)
            changeset = force_change(changeset, :email_verification_token, token)
            |> force_change(:email_verified, false)
            Mailer.send_email_validation_email(params.email, token)
          end

          if Map.has_key?(params, :password) and params.password != nil do
            changeset = force_change(changeset, :failed_login_attempts, 0)
            |> force_change(:login_lock, nil)
            |> generate_password_hash
          end

          Repo.update!(changeset)

          conn
          |> put_status(:ok)
          |> render("show.json", player: player)
        else
          conn
          |> put_status(:unprocessable_entity)
          |> render(Eden.ChangesetView, "error.json", changeset: changeset)
        end
    end
  end

  def verify_email(conn, %{"token" => token}) do
    case Phoenix.Token.verify(conn, @verify_email_salt, token, max_age: email_verification_token_ttl) do
      {:ok, player_id} ->
        case Repo.get(Player, player_id) do
          nil ->
            conn |> send_resp(:unprocessable_entity, "")
          player ->
            case player.email_verification_token === token do
              true ->
                Repo.update!(%{player | email_verification_token: nil, email_verified: true})
                conn |> send_resp(:ok, "")
              false ->
                conn |> send_resp(:unprocessable_entity, "")
            end
        end
      {:error, _} ->
        conn |> send_resp(:unprocessable_entity, "")
    end
  end

  def send_password_reset_email(conn, %{"search" => search}) do
    player = nil
    case Repo.get_by!(Player, login: search) do
      nil ->
        case Repo.get_by!(Player, email: search) do
          nil ->
            conn
            |> send_resp(:not_found, "")
          result ->
            player = result
        end
      result ->
        player = result
    end

    case player do
      nil ->
        conn
        |> send_resp(:not_found, "")
      player ->
        token = Phoenix.Token.sign(conn, @password_reset_salt, player.id)
        player = Repo.update!(%{player | password_reset_token: token})

        Mailer.send_password_reset_email(player)
        conn
        |> put_flash(:info, "Password reset email sent.")
        |> assign(:password_reset_token, token)
        |> send_resp(:ok, "")
    end
  end

  def reset_password(conn, %{"token" => token, "password" => password, "password_confirmation" => password_confirmation}) do
    case Phoenix.Token.verify(conn, @password_reset_salt, token, max_age: password_reset_token_ttl) do
      {:ok, player_id} ->
        case Repo.get(Player, player_id) do
          nil ->
            conn |> send_resp(:unprocessable_entity, "")
          player ->
            case player.password_reset_token === token do
              true ->
                player = Player.changeset(:update, player, %{password: password, password_confirmation: password_confirmation})
                if player.valid? do
                  player
                  |> generate_password_hash
                  |> Repo.update!
                  conn |> send_resp(:ok, "")
                else
                  conn
                    |> put_status(:unprocessable_entity)
                    |> render(Eden.ChangesetView, "error.json", changeset: player)
                end
              false ->
                conn |> send_resp(:unprocessable_entity, "")
            end
        end
      {:error, _} ->
        conn |> send_resp(:unprocessable_entity, "")
    end
  end

  def login(conn, %{"login" => login, "password" => password}) do
    player = if is_nil(login) do
      nil
    else
      Repo.get_by(Player, login: login)
    end

    login(player, password, conn)
  end

  def logout(conn, _) do
    assigns = Map.delete(conn.assigns, :current_player)

    %{conn | assigns: assigns}
    |> delete_session(:current_player)
    |> send_resp(:ok, "")
  end

  defp login(player, _password, conn) when is_nil(player) do
    conn
    |> send_resp(:unprocessable_entity, ~S({"errors": ["Must provide a login."]}))
  end

  defp login(_player, password, conn) when is_nil(password) do
    conn
    |> send_resp(:unprocessable_entity, ~S({"errors": ["Must provide a password."]}))
  end

  defp login(player, password, conn) when is_map(player) do
    cond do
      Comeonin.Bcrypt.checkpw(password, player.hash) ->
        player = Repo.update!(%{player | failed_login_attempts: 0, last_login: Ecto.DateTime.utc})
        conn
        |> put_session(:current_player, player.id)
        |> send_resp(:ok, "")
      true ->
        conn
        |> send_resp(:unprocessable_entity, ~S({"errors": ["Provided login/password pair did not return any matches."]}))
    end
  end

  def delete(conn, %{"id" => id}) do
    player = Repo.get!(Player, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(player)

    send_resp(conn, :no_content, "")
  end

  defp password_reset_token_ttl do
    Application.get_env(:eden, :password_reset_token_ttl)
  end

  defp email_verification_token_ttl do
    Application.get_env(:eden, :email_verification_token_ttl)
  end

  defp generate_password_hash(changeset) do
    put_change(changeset, :hash, hashpwsalt(get_change(changeset, "password")))
  end
end
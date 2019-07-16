defmodule ExmudWeb.AuthController do
  @moduledoc """
  Manages authentication lifecycle.
  """

  use ExmudWeb, :controller
  import OK, only: [success: 1, failure: 1]

  #
  # Signup Stuff
  #

  @spec show_signup_form(Plug.Conn.t(), any) :: Plug.Conn.t()
  def show_signup_form(conn, _params) do
    conn
    |> render("signup.html",
      changeset: Exmud.Account.Profile.changeset(%Exmud.Account.Profile{}),
      has_email_error?: false,
      has_nickname_error?: false
    )
  end

  @spec process_signup_form(Plug.Conn.t(), any) :: Plug.Conn.t()
  def process_signup_form(conn, params) do
    form = params["signup_form"]

    case Exmud.Account.signup(form) do
      success(player) ->
        conn
        |> put_flash(:success, "Welcome! You have been automatically logged in!")
        |> put_session("player", player)
        |> put_session("player_authenticated?", true)
        |> redirect(to: "/")

      failure(changeset) ->
        conn
        |> put_flash(:error, "Something went wrong. Please see errors below.")
        |> render("signup.html",
          changeset: changeset,
          has_email_error?: Exmud.Util.changeset_has_error?(changeset, :email),
          has_nickname_error?: Exmud.Util.changeset_has_error?(changeset, :nickname)
        )
    end
  end

  #
  # Login Stuff
  #

  @spec show_login_form(Plug.Conn.t(), any) :: Plug.Conn.t()
  def show_login_form(conn, _params) do
    conn
    |> render("login.html",
      changeset: ExmudWeb.LoginFormSchema.changeset(%ExmudWeb.LoginFormSchema{})
    )
  end

  @doc """
  This action is where the login form is received and processed.

  If an email identity is found a login email will be sent to the appropriate address. Will not state whether or not an
  account was found.
  """
  @spec send_login_token(Plug.Conn.t(), any) :: Plug.Conn.t()
  def send_login_token(conn, _params = %{"login_form" => %{"email" => email}}) do
    Exmud.Account.send_login_email(email)

    conn
    |> put_flash(:success, "Login token has been sent to provided email address.")
    |> redirect(to: "/login/token")
  end

  @spec show_login_token_form(Plug.Conn.t(), any) :: Plug.Conn.t()
  def show_login_token_form(conn, _params) do
    conn
    |> render("token.html",
      changeset: ExmudWeb.TokenFormSchema.changeset(%ExmudWeb.TokenFormSchema{})
    )
  end

  @doc """
  This action is where a login token is validated and, if correct, a player is logged in.

  The player can reach this action by entering the login token manually into the token form, or by following the link
  provided in the login email.
  """
  @spec validate_login_token(Plug.Conn.t(), any) :: Plug.Conn.t()
  def validate_login_token(conn, %{"token_form" => %{"token" => token}}) do
    case Exmud.Account.verify_login_token(token) do
      success(player) ->
        conn
        |> put_flash(:success, "You have been logged in!")
        |> put_session("player", player)
        |> put_session("player_authenticated?", true)
        |> redirect(to: "/")

      failure(error) ->
        conn
        |> put_flash(:error, "Failed to verify token due to following error: #{error}")
        |> redirect(to: "/login/token")
    end
  end

  #
  # Logout Stuff
  #

  @spec logout(Plug.Conn.t(), any) :: Plug.Conn.t()
  def logout(conn, _params) do
    conn
    |> put_flash(:success, "You have been logged out!")
    |> configure_session(drop: true)
    |> redirect(to: "/")
  end
end

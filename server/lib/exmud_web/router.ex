defmodule ExmudWeb.Router do
  @moduledoc false

  use ExmudWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
    plug :fetch_session
    plug ExmudWeb.Plug.SetPlayer

    # Why does the token sent back to server not pass the check?
    # plug :protect_from_forgery

    plug :put_secure_browser_headers
  end

  if Mix.env() == :dev do
    forward "/sent_emails", Bamboo.SentEmailViewerPlug
  end

  scope "/api", ExmudWeb do
    pipe_through :api

    get "/csrf-token", CsrfTokenController, :get_token

    # Auth related stuff
    post "/authenticate/email", PlayerAuthController, :authenticate_via_email
    get "/authenticate/email/:token", PlayerAuthController, :validate_auth_token
    post "/authenticate/token", PlayerAuthController, :validate_auth_token
    post "/logout", PlayerAuthController, :logout

    # Player related stuff
    post "/players/create", PlayerController, :create
    post "/players/delete", PlayerController, :delete
    post "/players/get", PlayerController, :get
    post "/players/update", PlayerController, :update

    # Authenticated Player stuff
    get "/player", PlayerController, :get_authenticated_player
    get "/player/settings", PlayerController, :get_authenticated_player_settings
    post "/player/settings", PlayerController, :save_authenticated_player_settings

    # Character related stuff
    post "/characters/list-player-characters", CharacterController, :list_player_characters
    post "/characters/create", CharacterController, :create
    post "/characters/delete", CharacterController, :delete
    post "/characters/get", CharacterController, :get
    post "/characters/update", CharacterController, :update
  end
end

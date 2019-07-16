defmodule ExmudWeb.Router do
  use ExmudWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug ExmudWeb.Plug.SetPlayer
    plug :fetch_flash
    plug Phoenix.LiveView.Flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  if Mix.env() == :dev do
    forward "/sent_emails", Bamboo.SentEmailViewerPlug
  end

  scope "/", ExmudWeb do
    pipe_through :browser

    get "/", PageController, :index
    get "/login", AuthController, :show_login_form
    post "/login", AuthController, :send_login_token
    get "/login/token", AuthController, :show_login_token_form
    post "/login/token", AuthController, :validate_login_token
    get "/login/:token", AuthController, :validate_login_token
    get "/logout", AuthController, :logout
    live "/signup", SignupLive
    resources "/profiles", ProfileController
    resources "/players", PlayerController
    resources "/simulations", SimulationController
    resources "/callbacks", CallbackController
    resources "/simulation_callbacks", SimulationCallbackController
  end
end

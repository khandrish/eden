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
    plug NavigationHistory.Tracker
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
    live "/datatable", DatatableLive
    resources "/profiles", ProfileController
    resources "/players", PlayerController
    resources "/muds", MudController
    resources "/callbacks", CallbackController, except: [:create, :delete, :new]

    resources "/mud_callbacks", MudCallbackController, only: [:edit, :show, :update]

    resources "/templates", TemplateController, except: [:new]

    resources "/template_callbacks", TemplateCallbackController, only: [:edit, :show, :update]
  end

  scope "/muds/:mud_id", ExmudWeb do
    pipe_through :browser

    resources "/templates", TemplateController, only: [:new]
  end
end

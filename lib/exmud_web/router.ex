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
    plug ExmudWeb.Plug.AssignSlugs
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

    # Auth related stuff
    get "/login", AuthController, :show_login_form
    post "/login", AuthController, :send_login_token
    get "/login/token", AuthController, :show_login_token_form
    post "/login/token", AuthController, :validate_login_token
    get "/login/:token", AuthController, :validate_login_token
    get "/logout", AuthController, :logout

    # Callback related stuff
    resources "/callbacks", CallbackController, except: [:create, :delete, :new]

    # Engine related stuff
    resources "/mud_callbacks", MudCallbackController, only: [:edit, :show, :update]

    get "/muds/build", BuildController, :index

    resources "/muds", MudController, param: "slug" do
      get "/build", BuildController, :show
      resources "/build/prototypes", PrototypeController, param: "slug"
      resources "/build/templates", TemplateController, param: "slug"
      resources "/build/categories", CategoryController, param: "slug"
    end

    # Player related stuff
    resources "/players", PlayerController
    resources "/profiles", ProfileController
    live "/signup", SignupLive
  end
end

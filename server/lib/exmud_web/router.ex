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

    # Auth related stuff
    post "/authenticate/email", PlayerAuthController, :authenticate_via_email
    get "/authenticate/email/:token", PlayerAuthController, :validate_auth_token
    post "/logout", PlayerAuthController, :logout
    post "/authenticate/token", PlayerAuthController, :validate_auth_token
    get "/csrf-token", CsrfTokenController, :get_token
    get "/player", PlayerController, :get_authenticated_player
    # get "/logout", AuthController, :logout

    # Callback related stuff
    # resources "/callbacks", CallbackController, except: [:create, :delete, :new]

    # Engine related stuff
    # resources "/mud_callbacks", MudCallbackController, only: [:edit, :show, :update]

    # get "/muds/build", BuildController, :index

    # resources "/muds", MudController, param: "slug" do
    #   get "/build", BuildController, :show
    #   resources "/build/prototypes", PrototypeController, param: "slug"
    #   resources "/build/templates", TemplateController, param: "slug"
    #   resources "/build/categories", CategoryController, only: [:index], param: "slug"
    # end

    # Player related stuff
    resources "/players", PlayerController, except: [:new, :edit]
    # resources "/profiles", ProfileController
    # live "/signup", SignupLive
  end
end

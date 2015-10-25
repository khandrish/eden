defmodule Eden.Router do
  use Eden.Web, :router

  pipeline :api do
    plug :accepts, ["json"]
    plug :fetch_session
    plug :put_secure_browser_headers
    plug Eden.Plug.JsonApi
  end

  pipeline :authenticated do
    plug Eden.Plug.Authenticated
  end

  scope "/api", Eden do
    pipe_through :api

    resources "/players", PlayerController, except: [:new, :edit]
      post "/send-password-reset-email", PlayerController, :send_password_reset_email
      post "/verify-email", PlayerController, :verify_email
      post "/login", PlayerController, :login
      post "/logout", PlayerController, :logout

    resources "characters", CharacterController, except: [:new, :edit]

    scope "/sandbox" do
      pipe_through :authenticated

      get "/token", TokenController, :token
    end

    
  end
end

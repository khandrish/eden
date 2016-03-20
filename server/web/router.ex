defmodule Eden.Router do
  use Eden.Web, :router

  pipeline :api do
    plug :accepts, ["json"]
    plug :fetch_session
    plug :put_secure_browser_headers
    plug Eden.Plug.JsonApi
  end

  scope "/", Eden do
    pipe_through :api

    get "/token", TokenController, :get_token
  end
end

defmodule ExmudWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :exmud

  # socket "/socket", ExmudWeb.ClientSocket,
  #   websocket: true,
  #   longpoll: false

  # Serve at "/" the static files from "priv/static" directory.
  #
  # You should set gzip to true if you are running phx.digest
  # when deploying your static files in production.
  plug Plug.Static,
    at: "/",
    from: :exmud,
    gzip: false,
    only: ~w(css fonts images js favicon.ico robots.txt)

  # Code reloading can be explicitly enabled under the
  # :code_reloader configuration of your endpoint.
  if code_reloading? do
    plug Phoenix.CodeReloader
  end

  plug Plug.RequestId
  plug Plug.Logger

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Phoenix.json_library()

  plug Plug.MethodOverride
  plug Plug.Head

  # The session will be stored in the cookie and signed,
  # this means its contents can be read but not tampered with.
  # Set :encryption_salt if you would also like to encrypt it.
  plug Plug.Session,
    store: :redis,
    key: "sid",
    http_only: true

  plug Corsica,
    origins: "http://localhost:8080",
    allow_credentials: true,
    allow_headers: ["Content-Type", "x-csrf-token"],
    log: [rejected: :error, invalid: :warn, accepted: :debug]

  plug ExmudWeb.Router
end

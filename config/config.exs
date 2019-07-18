# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :exmud,
  ecto_repos: [Exmud.Repo]

# Configures the endpoint
config :exmud, ExmudWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "9W/QZ3iU5+9TFpwlAPVG1zwlO94sfqDaSn+J0l4rwMLwKfq+L7CgVAs18kOQIZ7d",
  render_errors: [view: ExmudWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Exmud.PubSub, adapter: Phoenix.PubSub.PG2],
  live_view: [
    signing_salt: "eq1EMSpEwuOqxyc2o5ehOrSEg1fMGEm3"
  ]

# Configures Hammer
config :hammer,
  backend: {Hammer.Backend.ETS, [expiry_ms: 60_000 * 60 * 4, cleanup_interval_ms: 60_000 * 10]}

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Set the environment so code can safely check in production
config :exmud, env: Mix.env()

config :exmud, :openid_connect_providers,
  google: [
    discovery_document_uri: "https://accounts.google.com/.well-known/openid-configuration",
    client_id: System.get_env("GOOGLE_OAUTH_CLIENT_ID"),
    client_secret: System.get_env("GOOGLE_OAUTH_CLIENT_SECRET"),
    redirect_uri: "Doesn't matter as this will be replaced with appropriate value",
    response_type: "code",
    scope: "openid email profile"
  ]

config :exmud,
  no_reply_email_address: "no-reply@exmud",
  nickname_min_length: 2,
  nickname_max_length: 30,
  nickname_format: ~r/[a-zA-Z0-9 ]/,
  callback_modules: []

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"

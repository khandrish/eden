# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :exmud,
  ecto_repos: [Exmud.Repo],
  generators: [binary_id: true]

config :exmud, Exmud.Repo,
  migration_timestamps: [type: :utc_datetime_usec]

# Configures the endpoint
config :exmud, ExmudWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "9W/QZ3iU5+9TFpwlAPVG1zwlO94sfqDaSn+J0l4rwMLwKfq+L7CgVAs18kOQIZ7d",
  render_errors: [view: ExmudWeb.ErrorView, accepts: ~w(json)],
  pubsub: [name: Exmud.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Hammer
config :hammer,
  backend: {Hammer.Backend.ETS, [expiry_ms: 60_000 * 60 * 4, cleanup_interval_ms: 60_000 * 10]}

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Set the environment so code can safely check environment in production
config :exmud, env: Mix.env()

config :exmud,
  signup_player_token_ttl: String.to_integer(System.get_env("SIGNUP_PLAYER_TOKEN_TTL", "604800")),
  email_format: Regex.compile!(System.get_env("EMAIL_FORMAT", "^.+@.+$")),
  email_max_length: String.to_integer(System.get_env("EMAIL_MAX_LENGTH", "254")),
  email_min_length: String.to_integer(System.get_env("EMAIL_MIN_LENGTH", "3")),
  login_token_ttl: String.to_integer(System.get_env("LOGIN_TOKEN_TTL", "900")),
  nickname_format: Regex.compile!(System.get_env("NICKNAME_FORMAT", "^[a-zA-Z0-9 ]+$")),
  nickname_max_length: String.to_integer(System.get_env("NICKNAME_MAX_LENGTH", "30")),
  nickname_min_length: String.to_integer(System.get_env("NICKNAME_MIN_LENGTH", "2")),
  no_reply_email_address: System.get_env("NO_REPLY_EMAIL_ADDRESS", "no-reply@exmud")

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"

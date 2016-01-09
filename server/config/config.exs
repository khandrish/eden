# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# Configures the endpoint
config :eden, Eden.Endpoint,
  url: [host: "localhost"],
  root: Path.dirname(__DIR__),
  secret_key_base: "Z05Np74GCACMLSv8fMUhrLHl9M4AcvEL8qy2a1JzoZDG5KS4NFpjws+kRkSuMgUC",
  render_errors: [accepts: ~w(html json)],
  pubsub: [name: Eden.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures the player session.
config :eden, :player_session,
  ttl: 60 * 60 * 24 * 14 # 14 days in seconds

config :eden, :pools,
  example: %{size: 1,
             max_overflow: 0,
             worker_module: Eden.Pool.Example}

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"

# Configure phoenix generators
config :phoenix, :generators,
  migration: true,
  binary_id: false

config :eden,
  mailgun_domain: "https://api.mailgun.net/v3/sandbox28310e312b6841c78098ece145a4e653.mailgun.org",
  mailgun_key: "key-9de238d170019e92fdd3d4f3877990dc",
  password_reset_token_ttl: 60 * 60 * 24, # One Day
  email_verification_token_ttl: 60 * 60 * 24 * 7, # One Week
  mailgun_client_mode: :prod,
  mailgun_test_file_path: "/tmp/mailgun.json"

config :eden, :game,
  time: %{}

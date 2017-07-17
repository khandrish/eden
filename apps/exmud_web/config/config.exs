# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# Configures the endpoint
config :exmud_web, Exmud.Web.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "XKydesA/+EV8tuIwltJH3PL1mowYA0FmSPD0hdEzvnz/5s7Yo/mZsWqfY6SQvPFQ",
  render_errors: [view: Exmud.Web.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Exmud.Web.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :phoenix, :generators,
  migration: false,
  model: false

config :exmud_web, Exmud.Web.Repo,
  adapter: Ecto.Adapters.Postgres,
  database: "exmud_web_#{Mix.env}",
  hostname: "localhost",
  pool_size: 10,
  username: "exmud_web"

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"

# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :exmud_portal,
  namespace: Exmud.Portal,
  ecto_repos: [Exmud.Portal.Repo]

# Configures the endpoint
config :exmud_portal, Exmud.Portal.Web.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "GONo8KMx1lXshTVsqWdOHMcKFegWcJGrYqzAlgL+uqd+CpjflpagTL1Js9XWdM8w",
  render_errors: [view: Exmud.Portal.Web.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Exmud.Portal.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]


config :exmud_portal, Exmud.Portal.Repo,
  adapter: Ecto.Adapters.Postgres,
  database: "exmud_portal_#{Mix.env}",
  hostname: "localhost",
  pool_size: 10,
  username: "exmud_portal"

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"

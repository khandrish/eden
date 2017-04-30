# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# Configures Elixir's Logger
config :logger, :console,
  format: "$time - $level - $metadata - $message\n",
  metadata: [:module, :function, :line]

config :exmud, ecto_repos: [Exmud.Repo]

config :exmud, Exmud.Repo,
  adapter: Ecto.Adapters.Postgres,
  database: "exmud_repo",
  username: "exmud_user",
  password: "exmud_password",
  hostname: "localhost",
  port: "5432"

config :exmud, :engine,
  command_context_callback: Exmud.Command.Context.Default,
  default_system_run_timeout: 1000 # milliseconds


# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"

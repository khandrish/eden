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

config :eden,
  systems: [Eden.System.World, Eden.System.Scheduler, Eden.System.Weather]

# These arguments are passed to each system at startup and are available to
# each system as environment variables.
config :eden,
  system_env: %{foo: "bar"}


# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"

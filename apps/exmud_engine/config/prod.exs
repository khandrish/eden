use Mix.Config

# Do not print debug messages to console in production
config :logger, :console,
  level: :info

# Finally import the config/prod.secret.exs
# which should be versioned separately.
import_config "prod.secret.exs"

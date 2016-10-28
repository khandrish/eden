use Mix.Config

config :logger,
  compile_time_purge_level: :info

# Finally import the config/prod.secret.exs
# which should be versioned separately.
import_config "prod.secret.exs"

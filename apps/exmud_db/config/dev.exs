use Mix.Config

# Do not include metadata nor timestamps in development logs
config :logger, :console, format: "[$level] $message\n"

# Configure your database
config :exmud_db, Exmud.DB.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "exmud",
  password: "exmud",
  database: "exmud_dev",
  hostname: "localhost",
  pool_size: 10

use Mix.Config

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :exmud_db, Exmud.DB.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "exmud",
  password: "exmud",
  database: "exmud_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox
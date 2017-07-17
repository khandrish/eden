use Mix.Config

# Print only warnings and errors during test
config :logger, level: :debug

config :exmud_engine, Exmud.Engine.Repo,
  password: "exmud_engine",
  pool: Ecto.Adapters.SQL.Sandbox
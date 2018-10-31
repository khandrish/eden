use Mix.Config

# Print only warnings and errors during test
config :logger, :console, level: :warn

config :exmud_engine, Exmud.Engine.Repo,
  password: "exmud_engine"

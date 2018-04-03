use Mix.Config

# Do not include metadata nor timestamps in development logs
config :logger, :console,
  format: "[$level] $message\n",
  level: :debug

config :exmud_engine, Exmud.Engine.Repo,
  password: "exmud_engine"
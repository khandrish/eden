use Mix.Config

# Print only warnings and errors during test
config :logger, :console, level: :warn

config :exmud_engine, Exmud.Engine.Repo,
  password: "exmud_engine",
  pool: Ecto.Adapters.SQL.Sandbox

config :exmud_engine,
  callbacks: [],
  command_sets: [],
  components: [],
  scripts: [],
  systems: [
    {"Idle", Exmud.Engine.Test.System.Idle},
    {"Interval", Exmud.Engine.Test.System.Interval}
  ]

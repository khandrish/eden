use Mix.Config

# Print only warnings and errors during test
config :logger, :console, level: :warn

config :game,
  callbacks: [],
  command_sets: [],
  components: [],
  scripts: [],
  systems: [{"Time", Exmud.Game.System.Time}, {"Weather", Exmud.Game.System.Weather}]

use Mix.Config

# Do not include metadata nor timestamps in development logs
config :logger, :console, format: "[$level] $message\n"

# Configure your database
config :exmud_player, Exmud.Player.Repo,
  database: "exmud_player_dev",
  password: "exmud_player"

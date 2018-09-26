use Mix.Config

# Print only warnings and errors during test
config :logger, :console, level: :warn

config :exmud_player, Exmud.Player.Repo,
  password: "exmud_player",
  pool: Ecto.Adapters.SQL.Sandbox
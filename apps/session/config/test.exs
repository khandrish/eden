use Mix.Config

# Print only warnings and errors during test
config :logger, :console, level: :warn

config :exmud_session, Exmud.Session.Repo,
  password: "exmud_session",
  pool: Ecto.Adapters.SQL.Sandbox
use Mix.Config

# Do not include metadata nor timestamps in development logs
config :logger, :console, format: "[$level] $message\n"

config :exmud_session, Exmud.Session.Repo,
  password: "exmud_session"

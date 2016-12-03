use Mix.Config

# Do not include metadata nor timestamps in development logs
config :logger, :console, format: "[$level] $message\n"

config :exmud, Exmud.Repo,
  username: "postgres",
  password: "",
  database: "exmud_test_repo"
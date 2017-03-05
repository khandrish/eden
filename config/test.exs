use Mix.Config

# Print only warnings and errors during test
config :logger, level: :debug

config :exmud, Exmud.Repo,
  username: "postgres",
  password: "",
  database: "exmud_test_repo"

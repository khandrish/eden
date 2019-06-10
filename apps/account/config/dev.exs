use Mix.Config

# Do not include metadata nor timestamps in development logs
config :logger, :console, format: "[$level] $message\n"

# Configure your database
config :exmud_account, Exmud.Account.Repo, password: "exmud_account"

use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :eden, Eden.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :debug

# Set a higher stacktrace during test
config :phoenix, :stacktrace_depth, 20

# Configure your database
config :eden, Eden.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "eden_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

config :comeonin, :bcrypt_log_rounds, 4

config :eden, mailgun_client_mode: :test
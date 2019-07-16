use Mix.Config

# Configure your database
config :exmud, Exmud.Repo,
  username: "exmud",
  password: "exmud",
  database: "exmud_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :exmud, ExmudWeb.Endpoint,
  http: [port: 4002],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

config :exredis,
  host: System.get_env("REDIS_URL"),
  reconnect: :no_reconnect,
  max_queue: :infinity

# Configure email
config :my_app, Exmud.Mailer, adapter: Bamboo.TestAdapter

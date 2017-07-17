use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :exmud_web, Exmud.Web.Endpoint,
  http: [port: 8080],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

config :exmud_web, Exmud.Web.Repo,
  password: "exmud_web",
  pool: Ecto.Adapters.SQL.Sandbox
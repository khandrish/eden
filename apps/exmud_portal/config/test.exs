use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :exmud_portal, Exmud.Portal.Web.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, :console, level: :warn

# Configure your database
config :exmud_portal, Exmud.Portal.Repo,
  password: "exmud_portal",
  pool: Ecto.Adapters.SQL.Sandbox

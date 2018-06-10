# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

config :exmud_engine, Exmud.Engine.Repo,
  adapter: Ecto.Adapters.Postgres,
  database: "exmud_engine_#{Mix.env()}",
  hostname: "localhost",
  pool_size: 10,
  username: "exmud_engine"

config :exmud_engine,
  callbacks: [],
  command_sets: [],
  components: [],
  scripts: [],
  systems: [],
  byte_size_to_compress: 1024,

  # The regex used by default to determine if an argument string matches for a Command.
  command_argument_regex: ~r/$/

config :exmud_engine,
  command_pipeline: [
    Exmud.Engine.Command.Middleware.BuildActiveCommandList
  ]

# It is also possible to import configuration files, relative to this
# directory. For example, you can emulate configuration per environment
# by uncommenting the line below and defining dev.exs, test.exs and such.
# Configuration from the imported file will override the ones defined
# here (which is why it is important to import them last).
#
import_config "#{Mix.env()}.exs"

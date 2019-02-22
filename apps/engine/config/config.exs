# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

config :exmud_engine, Exmud.Engine.Repo,
  database: "exmud_engine_#{Mix.env()}",
  hostname: "localhost",
  pool_size: 10,
  username: "exmud_engine"

config :exmud_engine,
  byte_size_to_compress: 1024,
  command_argument_regex: ~r/$/,
  command_pipeline: [],
  system_command_multi_match: nil,
  system_command_no_match: nil

# It is also possible to import configuration files, relative to this
# directory. For example, you can emulate configuration per environment
# by uncommenting the line below and defining dev.exs, test.exs and such.
# Configuration from the imported file will override the ones defined
# here (which is why it is important to import them last).
#
import_config "#{Mix.env()}.exs"

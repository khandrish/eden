# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

config :exmud_common, ecto_repos: []

config :exmud_common,
  # Database backoff strategy configuration
  db_transaction_retries: 9,
  db_transaction_retry_delay_base_in_ms: 1,
  db_transaction_retry_delay_cap_in_ms: 100

# It is also possible to import configuration files, relative to this
# directory. For example, you can emulate configuration per environment
# by uncommenting the line below and defining dev.exs, test.exs and such.
# Configuration from the imported file will override the ones defined
# here (which is why it is important to import them last).
#
#     import_config "#{Mix.env}.exs"

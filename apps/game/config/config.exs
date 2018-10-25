# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

config :exmud_game,
  # This Component must be present in the below Template.
  player_component: Exmud.Engine.Component.DefaultPlayerComponent,
  player_template: Exmud.Engine.Template.DefaultPlayerTemplate

config :exmud_enging,
  byte_size_to_compress: 1024, # Default value. Can be changed freely.
  command_argument_regex: ~r/$/, # See Exmud.Engine.Command
  command_pipeline: [
    Exmud.Game.Contributions.Core.Command.Middleware.FilterSystemCommands,
    Exmud.Game.Contributions.Core.Command.Middleware.BuildActiveCommandList,
    Exmud.Game.Contributions.Core.Command.Middleware.MatchCommand,
    Exmud.Game.Contributions.Core.Command.Middleware.ParseArgs,
    Exmud.Game.Contributions.Core.Command.Middleware.ExecuteMatchedCommand
  ],
  system_command_multi_match: Exmud.Game.Contributions.Core.Command.MultiMatch,
  system_command_no_match: Exmud.Game.Contributions.Core.Command.NoMatch

# It is also possible to import configuration files, relative to this
# directory. For example, you can emulate configuration per environment
# by uncommenting the line below and defining dev.exs, test.exs and such.
# Configuration from the imported file will override the ones defined
# here (which is why it is important to import them last).
#
import_config "#{Mix.env}.exs"

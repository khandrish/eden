# defmodule Exmud.Engine.Player do
#   @moduledoc """
#   A Player is a complex Game Object.
#
#   It has Command Sets, Tags, Locks, Components, and Scripts attached to provide basic out-of-the-box functionality that is fully extensible via config.
#   """
#
#   @typedoc """
#   An error which happened during an operation.
#   """
#   @type error :: term
#
#   @typedoc """
#   The id of an Object on which all operations are to take place.
#   """
#   @type object_id :: integer
#
#   import Exmud.Engine.Constants
#   import Exmud.Engine.Utils
#   alias Exmud.Engine.Component
#   alias Exmud.Engine.Object
#   alias Exmud.Engine.PlayerComponent
#
#   @player_component engine_cfg( :player_component )
#   @new_player_components engine_cfg( :new_player_components )
#   @new_player_command_sets engine_cfg( :new_player_command_sets )
#   @new_player_locks engine_cfg( :new_player_locks )
#   @new_player_links engine_cfg( :new_player_links )
#   @new_player_scripts engine_cfg( :new_player_scripts )
#   @new_player_tags engine_cfg( :new_player_tags )
#
#   @typedoc """
#   A unique identifier for a Player.
#   """
#   @type player_name :: String.t()
#
#   @spec create( player_name ) :: :ok | { :error, error }
#   def create( player_name ) do
#
#     components = normalize_callbacks( :components, [ @player_component | @new_player_components ] )
#     command_sets = normalize_callbacks( :command_sets, @new_player_command_sets )
#     locks = normalize_callbacks( :locks, @new_player_locks )
#     links = normalize_callbacks( :links, @new_player_links )
#     scripts = normalize_callbacks( :scripts, @new_player_scripts )
#     tags = normalize_callbacks( :tags, @new_player_tags )
#     object_id = Object.new!()
#     Enum.each(components, fn { callback_module, config } ->
#         :ok = Component.attach( object_id, callback_module, config )
#       end
#     )
#     Enum.each(command_sets, fn { callback_module, config } ->
#         :ok = CommandSet.attach( object_id, callback_module, config )
#       end
#     )
#     Enum.each(locks, fn { callback_module, config } ->
#         :ok = CommandSet.attach( object_id, callback_module, config )
#       end
#     )
#     # create a new object
#     # grab the configured options that determine what modules make up a player
#     # attach each of the things
#     # do all this in a transaction so it's all or nothing
#
#   end
#
#   @spec get_player( player_name ) :: { :ok, object_id } | { :error, :no_such_player }
#   def get_player( player_name ) do
#     result =
#       Object.query(
#         { :and,
#           [
#             { :attribute, @player_component, player_name_attribute(), player_name }
#           ]
#         }
#       )
#
#     case result do
#       { :ok, [ object_id ] } ->
#         { :ok, object_id }
#       _empty_result ->
#         { :error, :no_such_player }
#     end
#   end
#
#   defp normalize_callbacks( type, callbacks, normalized_callbacks \\ [] )
#   defp normalize_callbacks( _, [], normalized_callbacks ) do
#     Enum.reverse( normalized_callbacks )
#   end
#   defp normalize_callbacks( _, [ callback | other_callbacks ], normalized_callbacks ) when is_tuple(callback) do
#     normalize_callbacks( other_callbacks, [ callback, normalized_callbacks ] )
#   end
#   defp normalize_callbacks( _, [ callback | other_callbacks ], normalized_callbacks ) do
#     normalize_callbacks( other_callbacks, [ { callback, %{} }, normalized_callbacks ] )
#   end
# end

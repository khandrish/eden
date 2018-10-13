defmodule Exmud.Engine.Player do
  @moduledoc """
  This module provides helper methods around managing Players.

  A Player is simply a Game Object with specific functionality added to it. It does not have a physical presence in the Game, instead serving as the in-game representation of an Account.

  It is through the Player Object that Characters can be puppeted and the Game can be accessed.
  """

  @typedoc """
  An error which happened during an operation.
  """
  @type error :: term

  @typedoc """
  The id of an Object on which all operations are to take place.
  """
  @type object_id :: integer

  @typedoc """
  A unique identifier for a Player.
  """
  @type player_name :: String.t()

  alias Exmud.Engine.Component
  alias Exmud.Engine.Object
  alias Exmud.Engine.PlayerComponent
  alias Exmud.Engine.Spawner
  import Exmud.Engine.Constants
  import Exmud.Engine.Utils

  @player_component engine_cfg( :player_component )
  @player_template engine_cfg( :player_template )

  @spec create( integer, term ) :: :ok | { :error, error }
  def create( account_id, config \\ nil ) when is_integer( account_id ) do
    player_object = Object.new!()
    :ok = Component.attach( player_object, @player_component, %{ @player_component.account_id() => account_id } )
    Spawner.spawn( player_object, @player_template, config )
  end

  @spec lookup( account_id ) :: { :ok, object_id } | { :error, :no_such_player }
  def lookup( account_id ) when is_integer( account_id ) do
    result =
      Object.query(
        { :and,
          [
            { :attribute, @player_component, @player_component.account_id(), account_id }
          ]
        }
      )

    case result do
      { :ok, [ object_id ] } ->
        { :ok, object_id }
      _empty_or_error_result ->
        { :error, :no_such_player }
    end
  end
end

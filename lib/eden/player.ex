defmodule Eden.Player do
  @moduledoc """
  This module is the interface for managing the communication for and lifecycle
  of players. In this context a player is a representation of a human actor
  within the system. What that means in practice is up to the application using
  Eden as a dependency to decide.
  """

  # alias Eden.Component.Player, as: P
  # alias Eden.Entity
  # alias Eden.PlayerSup
  # alias Eden.Registry
  # require Logger
  # use GenServer

  # #
  # # API
  # #

  # def start_link(name) do
  #   GenServer.start_link(__MODULE__, name)
  # end
  

  # def new(name) do
  #   Logger.debug("Creating player with name `#{name}`")
  #   Entity.transaction(fn ->
  #     Entity.new()
  #     |> Entity.add_component(P)
  #     |> Entity.add_key(P, "name", name)
  #   end)

  #   name
  # end

  # def delete(name) do
  #   Logger.debug("Deleting player with name `#{name}`")
  #   end_session(name)
  #   Entity.transaction(fn ->
  #     Entity.
  #     Entity.new()
  #     |> Entity.add_component(P)
  #     |> Entity.add_key(P, "name", name)
  #   end)
  # end

  # def exists?(name) do
  #   Logger.debug("Checking existance of player `#{name}`")
  #   Entity.transaction(fn ->
  #     Entity.value_exists?(P, "name", name)
  #   end)
  # end

  # def end_session(name) do
  #   case Registry.find_by_name(name) do
  #     nil -> :ok
  #     player_session -> GenServer.call(player_session, :end_session)
  #   end
  # end

  # @doc """
  # Once a character is connected they can be listened to by any number of
  # interested parties. This method registers the calling process as being
  # interested in the output stream for that character.

  # The output stream contains output from the engine meant for the player,
  # examples being text output during combat, UI updates, chat messages, and
  # so on.
  # """
  # def listen() do
  #   # Assume character is connected and do the thing
  # end

  # @doc """
  # A connected player can puppet entities via this method.
  # """
  # def puppet(player, puppet) do
    
  # end

  # def session_exists?(name) do
  #   Logger.debug("Checking to see if session exists for player `#{name}`")
  #   Registry.name_registered?(name)
  # end

  # def start_session(name) do
  #   Logger.debug("Starting session for player `#{name}`")
  #   if exists?(name) do
  #     Logger.debug("Player `#{name}` exists")
  #     case session_exists?(name) do
  #       true ->
  #         Logger.warn("Session for player `#{name}` already started")
  #         :ok
  #       false ->
  #         Logger.info("Starting session for player `#{name}`")
  #         PlayerSup.start_player(name)
  #         :ok
  #     end
  #   else
  #     Logger.warn("Player `#{name}` does not exist")
  #     {:error, :no_such_player}
  #   end
    
  # end

  # #
  # # GenServer Callbacks
  # #
  # def init(name) do
  #   Logger.debug("Player session starting with name `#{name}`")
  #   :ok = Registry.register_name(name)
  #   {:ok, %{name: name}}
  # end

  # def handle_call(:end_session, _from, state) do
  #   {:stop, :normal, :ok, state}
  # end

  # def terminate(_reason, %{name: name} = state) do
  #   Registry.unregister_name(name)
  #   :ok
  # end

  # #
  # # Private Functions
  # #
end
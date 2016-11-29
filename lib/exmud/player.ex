defmodule Exmud.Player do
  @moduledoc """
  This module is the interface for managing the communication for and lifecycle
  of players. In this context a player is a representation of an external actor
  within the system. What that means in practice is up to the application using
  Exmud to decide.
  """

  alias Exmud.Component
  alias Exmud.Component.Player
  alias Exmud.Db
  alias Exmud.PlayerSessionSup
  alias Exmud.Registry
  alias Exmud.Repo
  alias Exmud.Schema.Player, as: P
  alias Exmud.Schema.PlayerData, as: PD
  import Ecto.Query
  require Logger
  use GenServer


  #
  # API
  #


  # player management

  def add(key) do
    case Repo.insert(P.changeset(%P{}, %{key: key})) do
      {:ok, _} -> {:ok, key}
      {:error, changeset} ->
        {:error, elem(Keyword.get(changeset.errors, :key), 0)}
    end
  end

  def exists?(key) do
    find(key) != nil
  end

  def remove(key) do
    case find(key) do
      nil -> :ok
      player ->
        case Repo.delete(player) do
          {:ok, _} -> :ok
          result -> result
        end
    end
  end

  # player data management

  def delete_key(player, key) do
    Repo.one(
      from data in PD,
      inner_join: player in assoc(data, :player), on: data.player_id == player.id,
      where: data.key == ^key,
      where: player.key == ^player,
      select: data
    )
    |> case do
      nil -> {:ok, nil}
      data ->
        case Repo.delete(data) do
          {:ok, data} -> :erlang.binary_to_term(data.value)
          result -> result
        end
    end
  end

  def get_key(player, key) do
    Repo.one(
      from player in P,
      inner_join: data in assoc(player, :player_data), on: data.player_id == player.id,
      where: data.key == ^key,
      where: player.key == ^player,
      select: data.value
    )
    |> case do
      nil -> nil
      result -> :erlang.binary_to_term(result)
    end
  end

  def has_key?(player, key) do
    Repo.one(
      from player in P,
      inner_join: data in assoc(player, :player_data), on: data.player_id == player.id,
      where: data.key == ^key,
      where: player.key == ^player,
      select: player.id
    ) != nil
  end

  def put_key(player, key, value) do
    find(player)
    |> case do
      nil -> {:error, :no_such_player}
      player ->
        id = player.id
        value = :erlang.term_to_binary(value)
        changeset = PD.changeset(%PD{}, %{player_id: id, key: key, value: value})
        case Repo.insert(changeset) do
          {:ok, _} -> {:ok, player.key}
          {:error, changeset} ->
            {:error, changeset.errors}
        end
    end
  end

  # player session management

  def has_active_session?(player) do
    Registry.name_registered?(player)
  end
  
  def send_output(players, output) when is_list(players) do
    players
    |> Enum.each(fn(player) ->
      Registry.whereis_name(player)
      |> GenServer.call({:send_output, output})
    end)
    players
  end
  
  def send_output(player, output) do
    send_output([player], output)
    |> hd()
  end

  def session_state(players) when is_list(players) do
    players
    |> Enum.map(fn(player) ->
      state = Registry.whereis_name(player)
      |> GenServer.call(:state)
      {player, state}
    end)
  end

  def session_state(player) do
    session_state([player])
    |> hd()
    |> elem(1)
  end

  def start_session(players, args \\ %{})
  def start_session(players, args) when is_list(players) do
    players
    |> Enum.map(fn(player) ->
      if exists?(player) === true do
        {:ok, _pid} = Supervisor.start_child(PlayerSessionSup, [player, args])
        player
      else
        {:error, :no_such_player}
      end
    end)
  end

  def start_session(player, args), do: hd(start_session([player], args))

  def stop_session(players, args \\ %{})
  def stop_session(players, args) when is_list(players) do
    players
    |> Enum.each(fn(player) ->
      case Registry.whereis_name(player) do
        nil -> :ok
        process -> GenServer.call(process, {:stop, args})
      end
    end)

    players
  end

  def stop_session(player, args), do: hd(stop_session([player], args))
  
  def stream_session_output(players, handler_fun) when is_list(players) do
    players
    |> Enum.map(fn(player) ->
      case Registry.whereis_name(player) do
        nil -> {player, {:error, :no_such_player}}
        process ->
          :ok = GenServer.call(process, {:stream_output, handler_fun})
          player
      end
    end)
  end
  
  def stream_session_output(player, handler_fun) do
    case hd(stream_session_output([player], handler_fun)) do
      {player, error} -> error
      player -> player
    end
  end

  # manage player puppets and access information about them

  def has_puppet? do

  end

  def puppet do

  end

  def unpuppet do

  end

  def which_puppets do

  end


  #
  # Private Functions
  #
  
  
  defp do_get_key(player, key) do
    Repo.one(
      from player in P,
      inner_join: data in assoc(player, :player_data), on: data.player_id == player.id,
      where: data.key == ^key,
      where: player.key == ^player,
      select: data.value
    )
  end


  defp find(key) do
    Repo.get_by(P, key: key)
  end
end

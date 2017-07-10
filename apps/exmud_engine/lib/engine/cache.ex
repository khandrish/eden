defmodule Exmud.Engine.Cache do
  @moduledoc false

  require Logger
  use GenServer

  @cache_table :cache

  def delete(key, category) do
    Logger.debug("Deleting key `#{key}` in category `#{category}`")
    true = :ets.delete(@cache_table, {key, category})
    :ok
  end

  def get(key, category) do
    Logger.debug("Getting key `#{key}` in category `#{category}`")
    case :ets.lookup(@cache_table, {key, category}) do
      [{_, data}] -> {:ok, data}
      [] -> {:error, :no_such_key}
    end
  end

  def exists?(key, category) do
    Logger.debug("Checking if key `#{key}` is exists in category `#{category}`")
    :ets.member(@cache_table, {key, category})
  end

  def put(key, category, value) do
    Logger.debug("Putting key `#{key}` in category `#{category}`")
    true = :ets.insert(@cache_table, {{key, category}, value})
    :ok
  end

  def update(key, category, value) do
    Logger.debug("Updating key `#{key}` in category `#{category}`")
    if exists?(key, category) do
      true = :ets.insert(@cache_table, {{key, category}, value})
      :ok
    else
      {:error, :no_such_key}
    end
  end


  #
  # Worker callback
  #


  @doc false
  def start_link do
    GenServer.start_link(__MODULE__, nil)
  end


  #
  # GenServer Callbacks
  #


  def init(_) do
    table = :ets.new(@cache_table, [:set, :named_table, :public])
    Logger.info("Cache table created.")
    {:ok, table}
  end
end
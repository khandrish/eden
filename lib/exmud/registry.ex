defmodule Exmud.Registry do
  @moduledoc """
  Wraps and abstracts away gproc, making working with the app easier and more
  concise given this applications use cases. Also makes creating pluggable
  registry logic easy in the future.
  """
  
  require Logger
  use GenServer

  @registry_table :registry
  
  def read_key(key, category) do
    Logger.debug("Reading key `#{key}` in category `#{category}`")
    case :ets.lookup(@registry_table, {key, category}) do
      [{_, data}] -> {:ok, data}
      [] -> {:error, :no_such_key}
    end
  end

  def register_key(key, category, value) do
    Logger.debug("Registering key `#{key}` in category `#{category}`")
    true = :ets.insert(@registry_table, {{key, category}, value})
    :ok
  end
  
  def unregister_key(key, category) do
    Logger.debug("Unregistering key `#{key}` in category `#{category}`")
    true = :ets.delete(@registry_table, {key, category})
    :ok
  end
  
  def key_registered?(key, category) do
    Logger.debug("Checking if key `#{key}` is registered in category `#{category}`")
    :ets.member(@registry_table, {key, category})
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
    table = :ets.new(@registry_table, [:set, :named_table, :public])
    Logger.info("Registry table created.")
    {:ok, table}
  end
end

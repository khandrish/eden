defmodule Exmud.Registry do
  @moduledoc """
  Wraps and abstracts away gproc, making working with the app easier and more
  concise given this applications use cases. Also makes creating pluggable
  registry logic easy in the future.
  """
  
  use GenServer
  
  @registry_table :registry
  
  def read_key(key) do
    case :ets.lookup(@registry_table, key) do
      [] -> {:error, :no_such_key}
      [{_key, value}] -> {:ok, value}
    end
  end
  
  def register_key(key, value) do
    case :ets.insert_new(@registry_table, {key, value}) do
      true -> :ok
      false -> :error
    end
  end
  
  def unregister_key(key) do
    true = :ets.delete(@registry_table, key)
    :ok
  end
  
  def key_registered?(key) do
    :ets.member(@registry_table, key)
  end
  
  
  #
  # Worker callback
  #
  
  
  @doc false
  def start_link() do
    GenServer.start_link(__MODULE__, [])
  end
  
  
  #
  # GenServer Callbacks
  #
  
  
  def init(_) do
    table = :ets.new(@registry_table, [:set, :named_table, :public])
    {:ok, table}
  end
end

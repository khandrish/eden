defmodule Exmud.Engine.Cache do
  @moduledoc false

  import Exmud.Engine.Utils
  require Logger

  def delete(category, key) do
    Cachex.del(cache(), {category, key})
    :ok
  end

  def exists?(category, key) do
    Cachex.exists?(cache(), {category, key})
  end

  def get(category, key) do
    case Cachex.get(cache(), {category, key}) do
      {:missing, _} -> {:error, :no_such_key}
      result -> result
    end
  end

  def list(category) do
    {:ok, stream} = Cachex.stream(cache())

    stream
    |> Stream.filter(fn({{cat, _}, _}) -> cat == category end)
    |> Stream.map(fn({{_category, key}, _callback}) -> key end)
    |> Enum.to_list()
  end

  def set(category, key, callback_module) do
    Logger.debug("Registering key `#{key}` in category `#{category}`")
    {:ok, _} = Cachex.set(cache(), {category, key}, callback_module)
    :ok
  end
end
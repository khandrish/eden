defmodule Conf do
  @moduledoc """
  Runtime configuration for applications.
  """
  use Application

  @doc false
  def start(_type, _args) do
    Conf.Supervisor.start_link()
  end

  def clear(app) do
    :ets.match_delete(Conf, {{app, :_}, :_})
    :ok
  end

  def delete(app, key) do
    :ets.delete(Conf, {app, key})
    :ok
  end

  def get(app, key, default \\ nil) when is_atom(app) and is_atom(key) do
    case :ets.lookup(Conf, {app, key}) do
      [result] ->
        result

      _ ->
        default
    end
  end

  def put(app, key, value) when is_atom(app) and is_atom(key) do
    true = :ets.insert(Conf, {{app, key}, value})
    :ok
  end

  def load(app, config) do
    Enum.each(config, fn key, value ->
      put(app, key, value)
    end)
  end
end

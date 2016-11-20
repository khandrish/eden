defmodule Exmud.Registry do
  @moduledoc """
  Wraps and abstracts away gproc, making working with the app easier and more
  concise given this applications use cases. Also makes creating pluggable
  registry logic easy in the future.
  """

  def whereis_name(name) do
    result = :global.trans({name, self()}, fn -> :global.whereis_name(name) end)
    case result do
      :undefined -> nil
      pid -> pid
    end
  end

  def name_registered?(name) do
    case whereis_name(name) do
      nil -> false
      _ -> true
    end
  end

  def register_name(name) do
    :yes == :global.trans({name, self()}, fn -> :global.register_name(name, self()) end)
  end

  def unregister_name(name) do
    :global.trans({name, self()}, fn -> :global.unregister_name(name) end)
  end
end

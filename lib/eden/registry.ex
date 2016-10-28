defmodule Eden.Registry do
  @moduledoc """
  Wraps and abstracts away gproc, making working with the app easier and more
  concise given this applications use cases. Also makes creating pluggable
  registry logic easy in the future.
  """

  def find_by_name(name) do
    case :gproc.where({:n, :l, name}) do
      :undefined -> nil
      pid -> pid
    end
  end

  def name_registered?(name) do
    case :gproc.where({:n, :l, name}) do
      :undefined -> false
      _ -> true
    end
  end

  def register_name(name) do
    true = :gproc.reg({:n, :l, name})
    :ok
  end

  def unregister_name(name) do
    true = :gproc.unreg({:n, :l, name})
    :ok
  end
end

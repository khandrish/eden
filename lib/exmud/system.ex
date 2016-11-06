defmodule Exmud.System do
  @moduledoc """
  systems form the backbone of the engine. They drive time and event based
  actions, covering everything from weather effects to triggering AI actions.
  """

  alias Exmud.SystemRunner

  def call(systems, message) when is_list(systems) do
    systems
    |> Enum.map(fn(system) ->
      {system, SystemRunner.call(system, message)}
    end)
  end

  def call(system, message) do
    call([system], message)
    |> hd()
    |> elem(1)
  end

  def cast(systems, message) when is_list(systems) do
    systems
    |> Enum.each(fn(system) ->
      SystemRunner.cast(system, message)
    end)

    systems
  end

  def cast(system, message) do
    cast([system], message)
    |> hd()
  end

  def deregister(systems) when is_list(systems) do
    systems
    |> Enum.each(fn(system) ->
      SystemRunner.deregister(system)
    end)

    systems
  end

  def deregister(system), do: hd(deregister([system]))

  def register(systems, args \\ %{})
  def register(systems, args) when is_list(systems) do
    systems
    |> Enum.each(fn(system) ->
      SystemRunner.register(system, args)
    end)

    systems
  end

  def register(system, args), do: hd(register([system], args))

  def registered?(systems) when is_list(systems) do
    systems
    |> Enum.map(fn(system) ->
      {system, SystemRunner.registered?(system)}
    end)
  end

  def registered?(system) do
    registered?([system])
    |> hd()
    |> elem(1)
  end

  def running?(systems) when is_list(systems) do
    systems
    |> Enum.map(fn(system) ->
      {system, SystemRunner.running?(system)}
    end)
  end

  def running?(system) do
    running?([system])
    |> hd()
    |> elem(1)
  end

  def start(systems, args \\ %{})
  def start(systems, args) when is_list(systems) do
    systems
    |> Enum.each(fn(system) ->
      SystemRunner.start(system, args)
    end)

    systems
  end

  def start(system, args), do: hd(start([system], args))

  def stop(systems, args \\ %{})
  def stop(systems, args) when is_list(systems) do
    systems
    |> Enum.each(fn(system) ->
      SystemRunner.stop(system, args)
    end)

    systems
  end

  def stop(system, args), do: hd(stop([system], args))
end

defmodule Exmud.Service do
  @moduledoc """
  Services form the backbone of the engine. They drive time and event based
  actions, covering everything from weather effects to triggering AI actions.
  """

  alias Exmud.ServiceRunner

  def call(services, message) when is_list(services) do
    services
    |> Enum.map(fn(service) ->
      {service, ServiceRunner.call(service)}
    end)
  end

  def call(service, message) do
    call([service], message)
    |> hd()
    |> elem(1)
  end

  def cast(services, message) when is_list(services) do
    services
    |> Enum.each(fn(service) ->
      ServiceRunner.cast(service)
    end)

    services
  end

  def cast(service, message) do
    cast([service], message)
    |> hd()
  end

  def deregister(services, args \\ %{}), do: deregister(services, args)

  def deregister(services, args) when is_list(services) do
    services
    |> Enum.each(fn(service) ->
      case :gproc.lookup_local_name({:service, service}) do
        :undefined -> :ok
        pid -> ServiceRunner.deregister(pid, args)
      end
    end)

    services
  end

  def deregister(service, args), do: hd(deregister([service], args))

  def register(services, args \\ %{}), do: register(services, args)
  def register(services, args) when is_list(services) do
    services
    |> Enum.each(fn(service) ->
      ServiceRunner.register(service, args)
    end)
  end

  def register(service, args), do: hd(register([service], args))

  def start(services, args \\ %{}), do: start(services, args)

  def start(services, args) when is_list(services) do
    services
    |> Enum.each(fn(service) ->
      ServiceRunner.start(service, args)
    end)

    services
  end

  def start(service, args), do: hd(start([service], args))

  def stop(services, args \\ %{}), do: stop(services, args)

  def stop(services, args) when is_list(services) do
    services
    |> Enum.each(fn(service) ->
      ServiceRunner.stop(service, args)
    end)

    services
  end

  def stop(service, args), do: hd(stop([service], args))
end

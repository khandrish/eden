defmodule Eden.System.World do
  @moduledoc """
  Manages the epoch date for the world from which everything else will be measured.
  """

  alias Eden.Entity
  alias Eden.Time
  use GenServer

  @world_system_component :world_system

  # API

  def epoch do
    GenServer.call(__MODULE__, :get_epoch)
  end

  def start_link(env) do
    GenServer.start_link(__MODULE__, env, name: __MODULE__)
  end

  # Callbacks
  @doc """
  Upon initialization the World system creates an epoch if none exists,
  otherwise the existing epoch is loaded.
  """
  def init(env) do
    # epoch = Entity.transaction(fn ->
    #   case Entity.list_with_components(@world_system_component) do
    #     [] ->
    #       epoch = Time.now_utc()
    #       Entity.new
    #       |> Entity.put_key(@world_system_component, "epoch", epoch)
    #       epoch
    #     [entity] ->
    #       Entity.get_key(entity, @world_system_component, "epoch")
    #   end
    # end)

    # {:ok, %{env: env, epoch: epoch}}
    {:ok, true}
  end

  def handle_call(:get_epoch, _from, %{epoch: epoch} = state) do
    {:reply, epoch, state}
  end

  #
  # Private Functions
  #
end

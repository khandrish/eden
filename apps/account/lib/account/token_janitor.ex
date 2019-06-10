defmodule Exmud.Account.TokenJanitor do
  @moduledoc """
  A GenServer which is responsible for cleaning up tokens.

  Removes expired tokens on a set, configurable, schedule as well as on demand.
  """
  use GenServer
  alias Exmud.Account.Repo
  alias Exmud.Account.Schema.AccountToken
  import Ecto.Query, only: [from: 2]

  @token_janitor_schedule Application.get_env(:exmud_account, :token_janitor_schedule, 60) * 1000

  @doc false
  def child_spec(_) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, []}
    }
  end

  # Client

  @doc false
  @spec start_link() :: {:ok, pid} | {:error, {:already_started, pid}}
  def start_link() do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  @doc """
  Delete a token asychronously
  """
  @spec async_delete(token :: String.t(), type :: String.t()) :: :ok
  def async_delete(token, type) do
    GenServer.cast(__MODULE__, {:delete, token, type})
  end

  # Server (callbacks)

  @doc false
  @impl true
  @spec init(term()) :: {:ok, nil}
  def init(_) do
    schedule_worker()
    {:ok, nil}
  end

  @doc false
  @impl true
  @spec handle_info(:cleanup, term()) :: {:noreply, nil}
  def handle_info(:cleanup, _state) do
    cleanup()
    schedule_worker()
    {:noreply, nil}
  end

  @doc false
  @impl true
  @spec handle_cast({:delete, token :: String.t(), type :: String.t()}, term()) :: {:noreply, nil}
  def handle_cast({:delete, token, type}, _state) do
    Exmud.Account.Token.delete(token, type)
    {:noreply, nil}
  end

  @spec cleanup() :: :ok
  defp cleanup() do
    query =
      from(token in AccountToken,
        where: not is_nil(token.expiry) and token.expiry < ^Timex.now()
      )

    Repo.delete_all(query)
    :ok
  end

  @spec schedule_worker() :: term()
  defp schedule_worker() do
    Process.send_after(self(), :cleanup, @token_janitor_schedule)
  end
end

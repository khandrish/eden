defmodule Exmud.Account.Application do
  @moduledoc false

  use Application

  @spec start(any(), any()) ::
          {:ok, pid()}
          | {:error, {:already_started, pid()} | {:shutdown, term()} | term()}
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      {Exmud.Account.Repo, []},
      Exmud.Account.TokenJanitor
    ]

    opts = [strategy: :one_for_one, name: Exmud.Account.Supervisor]
    Supervisor.start_link(children, opts)
  end
end

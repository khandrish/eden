ExUnit.configure(exclude: [pending: true])

ExUnit.start()

Ecto.Adapters.SQL.Sandbox.mode(Exmud.Account.Repo, :manual)

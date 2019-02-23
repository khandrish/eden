defmodule Exmud.Account.Repo do
  use Ecto.Repo, otp_app: :account, adapter: Ecto.Adapters.Postgres
end

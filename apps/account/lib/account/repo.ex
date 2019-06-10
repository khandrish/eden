defmodule Exmud.Account.Repo do
  use Ecto.Repo,
    otp_app: :exmud_account,
    adapter: Ecto.Adapters.Postgres
end

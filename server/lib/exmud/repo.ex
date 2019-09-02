defmodule Exmud.Repo do
  use Ecto.Repo,
    otp_app: :exmud,
    adapter: Ecto.Adapters.Postgres
end

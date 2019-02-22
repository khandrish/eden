defmodule Exmud.Engine.Repo do
  use Ecto.Repo,
    otp_app: :exmud_engine,
    adapter: Ecto.Adapters.Postgres
end

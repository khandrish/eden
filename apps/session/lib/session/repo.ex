defmodule Exmud.Session.Repo do
  use Ecto.Repo, otp_app: :session, adapter: Ecto.Adapters.Postgres
end

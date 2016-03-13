defmodule Eden.Schema.Session do
  use Eden.Web, :schema

  schema "sessions" do
    field :data, :map, virtual: true
    field :db_data, :binary
    field :expiry, Calecto.DateTimeUTC
    field :token, :binary_id
  end
end
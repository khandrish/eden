defmodule Exmud.Account.Player do
  @moduledoc false
  import Ecto.Changeset
  use Ecto.Schema

  @timestamps_opts [type: :utc_datetime_usec]
  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "players" do
    field :status, Exmud.Account.Enums.PlayerStatus
    has_one :profile, Exmud.Account.Profile

    timestamps()
  end

  def new(params \\ %{}) do
    %__MODULE__{}
    |> cast(params, [:status])
  end
end

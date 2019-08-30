defmodule Exmud.Account.Player do
  @moduledoc false
  use Ecto.Schema
  @timestamps_opts [type: :utc_datetime_usec]

  schema "players" do
    timestamps()
  end

  def new(), do: %__MODULE__{}
end

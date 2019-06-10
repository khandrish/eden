defmodule Exmud.Account.Schema.AccountToken do
  @moduledoc false

  import Ecto.Changeset
  use Ecto.Schema

  schema "account_token" do
    field(:token, :string)
    field(:type, :string)
    field(:expiry, :utc_datetime)
    belongs_to(:account, Exmud.Account.Schema.AccountModel, foreign_key: :account_id)
  end

  def new(params \\ %{}) do
    %__MODULE__{}
    |> cast(params, [:expiry, :token, :type, :account_id])
    |> validate_required([:token, :type, :account_id])
  end
end

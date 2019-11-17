defmodule Exmud.Account.Enums do
  @moduledoc false

  import EctoEnum

  defenum(PlayerStatus, :account_status, [:created, :invited, :pending])
end

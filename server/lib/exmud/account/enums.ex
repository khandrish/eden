defmodule Exmud.Account.Enums do
  import EctoEnum

  defenum(PlayerStatus, :account_status, [:invited, :registered])
end

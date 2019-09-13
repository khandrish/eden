defmodule Exmud.Repo.Migrations.CreatePlayerStatusEnum do
  use Ecto.Migration

  def up do
    Exmud.Account.Enums.PlayerStatus.create_type()
  end

  def down do
    Exmud.Account.Enums.PlayerStatus.drop_type()
  end
end

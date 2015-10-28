defmodule Eden.Repo.Migrations.CreateEntity do
  use Ecto.Migration

  def change do
    create table(:entities) do

      timestamps
    end

  end
end

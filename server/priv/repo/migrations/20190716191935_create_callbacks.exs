defmodule Exmud.Repo.Migrations.CreateCallbacks do
  use Ecto.Migration

  def change do
    create table(:callbacks, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :module, :string
      add :type, :string
      add :config, :map

      timestamps()
    end

    create unique_index(:callbacks, [:module])
    create index(:callbacks, [:type])
  end
end

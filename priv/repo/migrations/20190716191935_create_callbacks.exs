defmodule Exmud.Repo.Migrations.CreateCallbacks do
  use Ecto.Migration

  def change do
    create table(:callbacks) do
      add :module, :string
      add :type, :string
      add :default_args, :jsonb

      timestamps()
    end

    create unique_index(:callbacks, [:module])
    create index(:callbacks, [:type])
  end
end

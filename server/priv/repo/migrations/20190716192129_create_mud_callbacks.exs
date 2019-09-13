defmodule Exmud.Repo.Migrations.CreateEngineCallbacks do
  use Ecto.Migration

  def change do
    create table(:mud_callbacks, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :config, :map
      add :mud_id, references(:muds, on_delete: :delete_all, type: :binary_id)
      add :callback_id, references(:callbacks, on_delete: :delete_all, type: :binary_id)

      timestamps()
    end

    create index(:mud_callbacks, [:mud_id])
    create index(:mud_callbacks, [:callback_id])

    create unique_index(:mud_callbacks, [:callback_id, :mud_id], name: "mud_callback_index")
  end
end

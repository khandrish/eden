defmodule Exmud.Repo.Migrations.CreateSimulationCallbacks do
  use Ecto.Migration

  def change do
    create table(:simulation_callbacks) do
      add :default_config, :map
      add :simulation_id, references(:simulations, on_delete: :delete_all)
      add :callback_id, references(:callbacks, on_delete: :delete_all)

      timestamps()
    end

    create index(:simulation_callbacks, [:simulation_id])
    create index(:simulation_callbacks, [:callback_id])

    create unique_index(:simulation_callbacks, [:callback_id, :simulation_id],
             name: "simulation_callback_index"
           )
  end
end

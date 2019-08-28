defmodule Exmud.Repo.Migrations.CreatePrototypeTypes do
  use Ecto.Migration

  def change do
    create table(:prototype_types) do
      add :name, :string
      add :mud_id, references(:muds, on_delete: :delete_all)

      timestamps()
    end

    create index(:prototype_types, [:name])
    create unique_index(:prototype_types, [:mud_id, :name],
             name: "prototype_types_mud_index"
           )
  end
end

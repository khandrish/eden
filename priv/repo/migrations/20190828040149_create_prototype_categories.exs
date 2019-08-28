defmodule Exmud.Repo.Migrations.CreatePrototypeCategories do
  use Ecto.Migration

  def change do
    create table(:prototype_categories) do
      add :name, :string
      add :mud_id, references(:muds, on_delete: :delete_all)

      timestamps()
    end

    create index(:prototype_categories, [:name])
    create unique_index(:prototype_categories, [:mud_id, :name],
             name: "prototype_categories_mud_index"
           )
  end
end

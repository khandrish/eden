defmodule Exmud.Repo.Migrations.CreateDecoratorCategories do
  use Ecto.Migration

  def change do
    create table(:decorator_categories) do
      add :name, :string
      add :mud_id, references(:muds, on_delete: :delete_all)

      timestamps()
    end

    create index(:decorator_categories, [:name])
    create unique_index(:decorator_categories, [:mud_id, :name],
             name: "decorator_categories_mud_index"
           )
  end
end

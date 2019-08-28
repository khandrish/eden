defmodule Exmud.Repo.Migrations.CreateDecorators do
  use Ecto.Migration

  def change do
    create table(:decorators) do
      add :name, :string
      add :decorator_category_id, references(:decorator_categories, on_delete: :nilify_all)
      add :decorator_type_id, references(:decorator_types, on_delete: :nilify_all)

      timestamps()
    end

    create index(:decorators, [:decorator_category_id])
    create index(:decorators, [:decorator_type_id])
    create unique_index(:decorators, [:name])
  end
end

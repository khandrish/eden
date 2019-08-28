defmodule Exmud.Repo.Migrations.CreatePrototypeDecorators do
  use Ecto.Migration

  def change do
    create table(:prototype_decorators) do
      add :decorator_id, references(:decorators, on_delete: :delete_all)
      add :prototype_id, references(:prototypes, on_delete: :delete_all)

      timestamps()
    end

    create index(:prototype_decorators, [:decorator_id])
    create index(:prototype_decorators, [:prototype_id])
  end
end

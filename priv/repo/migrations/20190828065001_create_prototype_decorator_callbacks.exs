defmodule Exmud.Repo.Migrations.CreatePrototypeDecoratorCallbacks do
  use Ecto.Migration

  def change do
    create table(:prototype_decorator_callbacks) do
      add :default_config, :map
      add :callback_id, references(:callbacks, on_delete: :delete_all)
      add :prototype_decorator_id, references(:prototype_decorators, on_delete: :delete_all)

      timestamps()
    end

    create index(:prototype_decorator_callbacks, [:callback_id])
    create index(:prototype_decorator_callbacks, [:prototype_decorator_id])
  end
end

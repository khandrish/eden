defmodule Exmud.Repo.Migrations.CreateDecoratorCallbacks do
  use Ecto.Migration

  def change do
    create table(:decorator_callbacks) do
      add :default_config, :map
      add :decorator_id, references(:decorators, on_delete: :delete_all)
      add :callback_id, references(:callbacks, on_delete: :delete_all)

      timestamps()
    end

    create index(:decorator_callbacks, [:decorator_id])
    create index(:decorator_callbacks, [:callback_id])
  end
end

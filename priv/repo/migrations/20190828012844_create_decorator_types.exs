defmodule Exmud.Repo.Migrations.CreateDecoratorTypes do
  use Ecto.Migration

  def change do
    create table(:decorator_types) do
      add :name, :string
      add :mud_id, references(:muds, on_delete: :nothing)

      timestamps()
    end

    create unique_index(:decorator_types, [:mud_id, :name], name: "decorator_types_mud_index")
  end
end

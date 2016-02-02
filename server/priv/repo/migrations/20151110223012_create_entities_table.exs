defmodule Eden.Repo.Migrations.CreateEntity do
  use Ecto.Migration

  def change do
    create table(:entities, primary_key: false) do
      add :id, :uuid, primary_key: true, default: fragment("uuid_generate_v4()")
      add :components, :binary

      timestamps
    end
  end
end

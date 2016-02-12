defmodule Eden.Schema.Entity do
  use Ecto.Schema

  @primary_key {:id, :binary_id, autogenerate: true}

  schema "entities" do
    field :components, :binary

    timestamps
  end
end

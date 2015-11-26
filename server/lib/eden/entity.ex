defmodule Eden.Entity do
  use Ecto.Model

  @primary_key {:id, :binary_id, autogenerate: true}

  schema "entities" do
    field :components, :binary

    timestamps
  end

  @required_fields ~w(components)
  @optional_fields ~w()

  @doc """
  Creates a changeset based on the `model` and `params`.
  If `params` are nil, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ nil) do
    model
    |> cast(params, @required_fields, @optional_fields)
  end
end

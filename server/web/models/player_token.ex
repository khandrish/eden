defmodule Eden.PlayerToken do
  use Eden.Web, :model

  schema "player_tokens" do
    belongs_to :player, Eden.Player
    
    field :type, :string
    field :token, :binary_id
    field :expiry, :string

    timestamps
  end

  @required_fields ~w(player_id type expiry)
  @optional_fields ~w()

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
  end
end

defmodule ExmudWeb.TokenFormSchema do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  embedded_schema do
    field :token, :string
  end

  @spec changeset(__MODULE__.t()) :: Ecto.Changeset.t()
  def changeset(form = %__MODULE__{}), do: change(form)
end

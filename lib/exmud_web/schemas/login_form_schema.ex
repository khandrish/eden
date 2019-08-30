defmodule ExmudWeb.LoginFormSchema do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  embedded_schema do
    field :email, :string
  end

  @spec changeset(__MODULE__.t()) :: Ecto.Changeset.t()
  def changeset(form = %__MODULE__{}), do: change(form)

  @spec validate(Ecto.Changeset.t()) :: Ecto.Changeset.t()
  def validate(form = %Ecto.Changeset{}) do
    form
    |> validate_format(:email, ~r/.@./)
    |> validate_length(:email, min: 3)
    |> validate_length(:email, max: 255)
  end
end

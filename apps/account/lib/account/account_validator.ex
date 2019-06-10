defmodule Exmud.Account.AccountValidator do
  @moduledoc """
  Defines the callbacks that must be implemented for a custom validator to work correctly.
  """

  @callback validate_email(changeset :: Ecto.Changeset.t()) :: Ecto.Changeset.t()
  @callback validate_nickname(changeset :: Ecto.Changeset.t()) :: Ecto.Changeset.t()
  @callback validate_password(changeset :: Ecto.Changeset.t()) :: Ecto.Changeset.t()
  @callback validate_username(changeset :: Ecto.Changeset.t()) :: Ecto.Changeset.t()
end

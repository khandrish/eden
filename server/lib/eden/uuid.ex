defmodule Eden.UUID do
  def put_uuid(changeset) do
    Ecto.Changeset.put_change(changeset, :id, Ecto.UUID.generate())
  end
end
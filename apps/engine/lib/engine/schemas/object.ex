defmodule Exmud.Engine.Schema.Object do
  use Exmud.Common.Schema

  schema "object" do
    has_many(:command_sets, Exmud.Engine.Schema.CommandSet, foreign_key: :object_id)
    has_many(:components, Exmud.Engine.Schema.Component, foreign_key: :object_id)
    has_many(:links, Exmud.Engine.Schema.Link, foreign_key: :from_id)
    has_many(:locks, Exmud.Engine.Schema.Lock, foreign_key: :object_id)
    has_many(:scripts, Exmud.Engine.Schema.Script, foreign_key: :object_id)
    has_many(:tags, Exmud.Engine.Schema.Tag, foreign_key: :object_id)

    timestamps()
  end

  def new do
    %__MODULE__{}
    |> cast(%{}, [])
  end
end

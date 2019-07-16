defmodule Model.Object do
  import Ecto.Changeset

  use Ecto.Schema

  schema "object" do
    belongs_to(:object, Model.Simulation, foreign_key: :object_id)
    
    has_many(:command_sets, Model.CommandSet, foreign_key: :object_id)
    has_many(:components, Model.Component, foreign_key: :object_id)
    has_many(:links, Model.Link, foreign_key: :from_id)
    has_many(:locks, Model.Lock, foreign_key: :object_id)
    has_many(:scripts, Model.Script, foreign_key: :object_id)
    has_many(:tags, Model.Tag, foreign_key: :object_id)

    timestamps()
  end

  def new do
    %__MODULE__{}
  end
end

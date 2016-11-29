defmodule Exmud.Schema.Alias do
  use Ecto.Schema
  
  schema "alias" do
    field :alias, :string
    belongs_to :game_object, Exmud.Schema.GameObject
  end
end
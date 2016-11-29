defmodule Exmud.Schema.GameObjectCommandSet do
  use Ecto.Schema
  
  schema "game_object_command_set" do
    belongs_to :command_set, Exmud.Schema.CommandSet
    belongs_to :game_object, Exmud.Schema.GameObject
  end
end
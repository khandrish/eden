defmodule Exmud.Schema.CommandSet do
  use Ecto.Schema
  
  schema "command_set" do
    field :key, :string
    has_many :player_command_set, Exmud.Schema.PlayerCommandSet
    has_many :game_object_command_set, Exmud.Schema.GameObjectCommandSet
  end
end
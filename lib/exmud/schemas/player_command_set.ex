defmodule Exmud.Schema.PlayerCommandSet do
  use Ecto.Schema
  
  schema "player_command_set" do
    belongs_to :command_set, Exmud.Schema.CommandSet
    belongs_to :player, Exmud.Schema.Player
  end
end
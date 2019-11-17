defmodule ExmudWeb.PlayerView do
  use ExmudWeb, :view
  alias ExmudWeb.PlayerView

  def render("index.json", %{players: players}) do
    %{data: render_many(players, PlayerView, "player.json")}
  end

  def render("show.json", %{player: player}) do
    %{data: render_one(player, PlayerView, "player.json")}
  end

  def render("player.json", %{player: player}) do
    %{
      id: player.id,
      inserted_at: player.inserted_at,
      status: player.status,
      tos_accepted: player.tos_accepted,
      updated_at: player.updated_at
    }
  end
end

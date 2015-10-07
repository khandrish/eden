defmodule Eden.PlayerView do
  use Eden.Web, :view

  def render("index.json", %{players: players}) do
    %{data: render_many(players, Eden.PlayerView, "player.json")}
  end

  def render("show.json", %{player: player}) do
    %{data: render_one(player, Eden.PlayerView, "player.json")}
  end

  def render("player.json", %{player: player}) do
    %{id: player.id,
      name: player.name,
      email: player.email,
      last_login: player.last_login}
  end
end
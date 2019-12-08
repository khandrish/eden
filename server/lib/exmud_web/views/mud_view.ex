defmodule ExmudWeb.MudView do
  use ExmudWeb, :view
  alias ExmudWeb.MudView

  def render("index.json", %{muds: muds}) do
    %{data: render_many(muds, MudView, "mud.json")}
  end

  def render("show.json", %{mud: mud}) do
    %{data: render_one(mud, MudView, "mud.json")}
  end

  def render("check_name_and_get_slug.json", %{slug: slug}) do
    %{data: %{slug: slug}}
  end

  def render("mud.json", %{mud: mud}) do
    %{
      id: mud.id,
      inserted_at: mud.inserted_at,
      name: mud.name,
      description: mud.description,
      slug: mud.slug,
      player_id: mud.player_id,
      updated_at: mud.updated_at
    }
  end
end

defmodule ExmudWeb.SettingsView do
  use ExmudWeb, :view
  alias ExmudWeb.SettingsView

  def render("index.json", %{settings: settings}) do
    %{data: render_many(settings, SettingsView, "settings.json")}
  end

  def render("show.json", %{settings: settings}) do
    %{data: render_one(settings, SettingsView, "settings.json")}
  end

  def render("settings.json", %{settings: settings}) do
    %{
      playerId: settings.player_id,
      developerFeatureOn: settings.developer_feature_on,
      insertedAt: settings.inserted_at,
      updatedAt: settings.updated_at
    }
  end
end

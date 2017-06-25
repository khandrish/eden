defmodule ExmudUmbrella.Mixfile do
  use Mix.Project

  def project do
    [apps_path: "apps",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     aliases: aliases(),
     deps: deps()]
  end

  defp deps do
    []
  end

  defp aliases do
    ["test": ["ecto.drop --quiet -r Exmud.DB.Repo MIX_ENV=test",
              "ecto.create --quiet -r Exmud.DB.Repo MIX_ENV=test",
              "ecto.migrate -r Exmud.DB.Repo MIX_ENV=test",
              "test"]]
  end
end

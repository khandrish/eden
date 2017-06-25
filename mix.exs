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
    ["test": ["ecto.create --quiet -r Exmud.DB.Repo", "ecto.migrate -r Exmud.DB.Repo", "test"]]
  end
end

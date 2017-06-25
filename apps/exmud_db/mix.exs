defmodule Exmud.DB.Mixfile do
  use Mix.Project

  def project do
    [app: :exmud_db,
     version: "0.1.0",
     build_path: "../../_build",
     config_path: "../../config/config.exs",
     deps_path: "../../deps",
     lockfile: "../../mix.lock",
     elixir: "~> 1.4",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     aliases: aliases(),
     deps: deps()]
  end
  
  def application do
    # Specify extra applications you'll use from Erlang/Elixir
    [extra_applications: [:logger],
     mod: {Exmud.DB.Application, [:postgrex]}]
  end
  
  defp deps do
    [
      {:ecto, "~> 2.1.3"},
      {:postgrex, "~> 0.13.0"}
    ]
  end

  defp aliases do
    ["exmud.db.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
     "exmud.db.reset": ["ecto.drop", "ecto.setup"]]
  end
end

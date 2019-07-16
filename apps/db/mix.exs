defmodule Db.MixProject do
  @moduledoc false
  use Mix.Project

  def project do
    [
      app: :db,
      version: "0.1.0",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.9-rc",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:credo, "~> 1.0.2", only: [:dev, :test]},
      {:ecto, "~> 3.0.7"},
      {:ecto_sql, "~> 3.0"},
      {:ex_doc, ">= 0.19.3", only: :dev},
      {:excoveralls, ">= 0.10.5", only: :test},
      {:common, in_umbrella: true},
      {:faker, "~> 0.12.0", only: [:dev, :test]}
    ]
  end
end

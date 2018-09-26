defmodule Exmud.Engine.Mixfile do
  use Mix.Project

  def project do
    [
      # Standard arguments
      aliases: aliases(),
      app: :engine,
      deps: deps(),
      elixir: "~> 1.7.0",
      elixirc_paths: elixirc_paths(Mix.env()),
      version: "0.1.0",

      # Build arguments
      build_embedded: Mix.env() == :prod,
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",

      # Run arguments
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ],
      start_permanent: Mix.env() == :prod,
      test_coverage: [tool: ExCoveralls]
    ]
  end

  defp aliases do
    [
      test: [
        "ecto.drop -r Exmud.Engine.Repo --quiet MIX_ENV=test",
        "ecto.create -r Exmud.Engine.Repo --quiet MIX_ENV=test",
        "ecto.migrate -r Exmud.Engine.Repo --quiet MIX_ENV=test",
        "test"
      ]
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {Exmud.Engine.Application, []}
    ]
  end

  defp deps do
    [
      {:calendar, "~> 0.17.4"},
      {:credo, "~> 0.10.2", only: [:dev, :test]},
      {:e_queue, "~> 1.0"},
      {:ecto, "~> 2.2"},
      {:ex_doc, ">= 0.19.1", only: :dev},
      {:excoveralls, ">= 0.10.1", only: :test},
      {:common, in_umbrella: true},
      {:faker, "~> 0.10.0", only: [:dev, :test]},
      {:inch_ex, ">= 1.0.1", only: :docs},
      {:jason, "~> 1.1.1"},
      {:postgrex, "~> 0.13.5"},
      {:uuid, "~> 1.1"}
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]
end

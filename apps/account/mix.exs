defmodule Exmud.Player.Mixfile do
  use Mix.Project

  def project do
    [
      # Standard arguments
      app: :exmud_account,
      deps: deps(),
      elixir: "~> 1.8.1",
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

  def application do
    [
      extra_applications: [:logger],
      mod: {Exmud.Account.Application, []}
    ]
  end

  defp deps do
    [
      {:argon2_elixir, "~> 2.0"},
      {:calendar, "~> 0.17.4"},
      {:comeonin, "~> 5.0.0"},
      {:common, in_umbrella: true},
      {:credo, "~> 1.0.2", only: [:dev, :test]},
      {:ecto, "~> 3.0.7"},
      {:ecto_sql, "~> 3.0"},
      {:ex_doc, ">= 0.19.3", only: :dev},
      {:ex_pwned, "~> 0.1.4"},
      {:excoveralls, ">= 0.11.1", only: :test},
      {:faker, "~> 0.12.0", only: [:dev, :test]},
      {:inch_ex, ">= 2.0.0", only: :docs},
      {:postgrex, "~> 0.14.1"},
      {:timex, "~> 3.1"},
      {:uuid, "~> 1.1.8"}
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]
end

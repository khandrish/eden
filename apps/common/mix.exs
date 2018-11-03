defmodule Exmud.Common.Mixfile do
  use Mix.Project

  def project do
    [
      # Standard arguments
      app: :common,
      deps: deps(),
      elixir: "~> 1.7.0",
      elixirc_paths: elixirc_paths(Mix.env),
      version: "0.1.0",

      # Build arguments
      build_embedded: Mix.env == :prod,
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",

      # Run arguments
      preferred_cli_env: [
        "coveralls": :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test],
      start_permanent: Mix.env == :prod,
      test_coverage: [tool: ExCoveralls]
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:credo, "~> 0.10.2", only: [:dev, :test]},
      {:ecto, "~> 2.2"},
      {:ex_doc, ">= 0.19.1", only: :dev},
      {:excoveralls, ">= 0.10.1", only: :test},
      {:inch_ex, ">= 1.0.1", only: :docs}
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_),     do: ["lib"]
end
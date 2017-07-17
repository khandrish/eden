defmodule Exmud.Web.Mixfile do
  use Mix.Project

  def project do
    [
      # Standard arguments
      app: :exmud_web,
      deps: deps(),
      elixir: "~> 1.4",
      elixirc_paths: elixirc_paths(Mix.env),
      version: "0.1.0",

      # Build arguments
      build_embedded: Mix.env == :prod,
      build_path: "../../_build",
      compilers: [:phoenix, :gettext] ++ Mix.compilers,
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",

      # Run arguments
      preferred_cli_env: ["coveralls": :test, "coveralls.detail": :test, "coveralls.post": :test, "coveralls.html": :test],
      start_permanent: Mix.env == :prod,
      test_coverage: [tool: ExCoveralls]
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {Exmud.Web.Application, []}
    ]
  end

  defp deps do
    [
      {:absinthe, "~> 1.3"},
      {:absinthe_ecto, "~> 0.1.0"},
      {:calendar, "~> 0.17.2"},
      {:comeonin, "~> 3.0"},
      {:cowboy, "~> 1.0"},
      {:credo, "~> 0.5", only: [:dev, :test]},
      {:e_queue, "~> 1.0"},
      {:ecto, "~> 2.1.4"},
      {:ex_doc, ">= 0.14.5", only: :dev},
      {:excoveralls, ">= 0.7.0", only: :test},
      {:exmud_common, in_umbrella: true},
      {:exmud_engine, in_umbrella: true},
      {:exmud_player, in_umbrella: true},
      {:exmud_session, in_umbrella: true},
      {:faker, "~> 0.8.0"},
      {:gettext, "~> 0.11"},
      {:inch_ex, ">= 0.5.6", only: :docs},
      {:phoenix, "~> 1.3.0-rc.2"},
      {:phoenix_pubsub, "~> 1.0"},
      {:phoenix_ecto, "~> 3.0"},
      {:phoenix_html, "~> 2.6"},
      {:phoenix_live_reload, "~> 1.0", only: :dev},
      {:postgrex, "~> 0.13.0"},
      {:uuid, "~> 1.1"}
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_),     do: ["lib"]
end

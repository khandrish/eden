defmodule Exmud.MixProject do
  use Mix.Project

  def project do
    [
      app: :exmud,
      version: "0.1.0",
      elixir: "~> 1.9",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Exmud.Application, []},
      extra_applications: [:logger, :runtime_tools],
      start_phases: [init: []]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:bamboo, "~> 1.3"},
      {:defused, "~> 0.6.0"},
      {:ecto_sql, "~> 3.0"},
      {:ex_json_schema, "~> 0.6.1"},
      {:exconstructor, "~> 1.1"},
      {:gettext, "~> 0.11"},
      {:hammer, "~> 6.0"},
      {:hammer_plug, "~> 2.0"},
      {:jason, "~> 1.0"},
      {:maybe, "~> 1.0"},
      {:navigation_history, "~> 0.2.2"},
      {:ok, "~> 2.3"},
      {:phoenix, "~> 1.4.6"},
      {:phoenix_ecto, "~> 4.0"},
      {:phoenix_html, "~> 2.11"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:phoenix_live_view, github: "phoenixframework/phoenix_live_view"},
      {:phoenix_pubsub, "~> 1.1"},
      {:plug_cowboy, "~> 2.0"},
      {:poison, "~> 4.0.1"},
      {:postgrex, ">= 0.0.0"},
      {:redbird, "~> 0.4.0"},
      {:redix, "~> 0.10.2"},
      {:scribe, "~> 0.10.0"},
      {:typed_struct, "~> 0.1.4"},
      {:uuid, "~> 1.1.8"}
    ]
  end

  defp aliases do
    [
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"]
    ]
  end
end

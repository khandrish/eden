defmodule Exmud.Mixfile do
  use Mix.Project

  def project do
    [app: :exmud,
     build_embedded: Mix.env == :prod,
     compilers: Mix.compilers,
     deps: deps(),
     elixir: "~> 1.4",
     elixirc_paths: elixirc_paths(Mix.env),
     description: description(),
     package: package(),
     preferred_cli_env: ["coveralls": :test, "coveralls.detail": :test, "coveralls.post": :test, "coveralls.html": :test],
     start_permanent: Mix.env == :prod,
     test_coverage: [tool: ExCoveralls],
     version: "0.0.1",]
  end

  def application do
    [extra_applications: [:logger],
     mod: {Exmud, []}]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_),     do: ["lib"]

  defp deps do
    [{:apex, "~> 0.7.0"},
     {:calendar, "~> 0.17.1"},
     {:credo, "~> 0.5", only: [:dev, :test]},
     {:e_queue, "~> 1.0.1"},
     {:ecto, "~> 2.1.3"},
     {:excoveralls, ">= 0.6.1", only: :test},
     {:ex_doc, ">= 0.14.5", only: :dev},
     {:fsm, "~> 0.3.0"},
     {:gen_stage, "~> 0.11"},
     {:inch_ex, ">= 0.5.6", only: :docs},
     {:postgrex, "~> 0.13.0"},
     {:uuid, "~> 1.1"}]
  end

  defp description do
    """
    A toolkit for building and an engine for running text-based MU* games implemented in Elixir.
    """
  end

  defp package do
    [files: ["lib", "mix.exs", "README*", "LICENSE*"],
     licenses: ["MIT"],
     links: %{"GitHub" => "https://github.com/mononym/exmud"},
     maintainers: ["Chris Hicks"],
     name: :exmud]
  end
end

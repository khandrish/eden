defmodule Eden.Mixfile do
  use Mix.Project

  def project do
    [app: :eden,
     version: "0.0.1",
     elixir: "~> 1.2",
     elixirc_paths: elixirc_paths(Mix.env),
     compilers: [:phoenix] ++ Mix.compilers,
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps]
  end

  # Configuration for the OTP application
  #
  # Type `mix help compile.app` for more information
  def application do
    [mod: {Eden, []},
     applications: [:phoenix, :phoenix_html, :cowboy, :logger,
                    :phoenix_ecto, :postgrex, :gproc, :con_cache,
                    :tzdata]]
  end

  # Specifies which paths to compile per environment
  defp elixirc_paths(:test), do: ["lib", "web", "test/support"]
  defp elixirc_paths(_),     do: ["lib", "web"]

  # Specifies your project dependencies
  #
  # Type `mix help deps` for examples and options
  defp deps do
    [{:phoenix, "~> 1.1"},
     {:phoenix_ecto, "~> 2.0"},
     {:phoenix_html, "~> 2.3"},
     {:postgrex, ">= 0.0.0"},
     {:phoenix_live_reload, "~> 1.0", only: :dev},
     {:cowboy, "~> 1.0"},
     {:mailgun, "~> 0.1.2"},
     {:comeonin, "~> 1.2.2"},
     {:gproc, "~> 0.5.0"},
     {:poolboy, "~> 1.5"},
     {:con_cache, "~> 0.10.0"},
     {:corsica, "~> 0.4"},
     {:phoenix_calendar, "~> 0.1.2"},
     {:calecto, "~> 0.5.0"},
     {:pipe, "~> 0.0.2"}]
  end
end

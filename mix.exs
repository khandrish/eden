defmodule Eden.Mixfile do
  use Mix.Project

  def project do
    [app: :eden,
     version: "0.0.1",
     elixir: "~> 1.3",
     elixirc_paths: elixirc_paths(Mix.env),
     compilers: Mix.compilers,
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps]
  end

  # Configuration for the OTP application
  #
  # Type `mix help compile.app` for more information
  def application do
    [mod: {Eden, []},
     applications: [:logger, :calendar, :amnesia]]
  end

  # Specifies which paths to compile per environment
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_),     do: ["lib"]

  # Specifies your project dependencies
  #
  # Type `mix help deps` for examples and options
  defp deps do
    [{:amnesia, "~> 0.2.0"},
     {:apex, "~> 0.5.2"},
     {:calendar, "~> 0.16.0"},
     {:fsm, "~> 0.2.0"},
     {:pipe, "~> 0.0.2"},
     {:timex, "~> 3.0"}]
  end
end
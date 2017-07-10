defmodule Exmud.Umbrella.Mixfile do
  use Mix.Project

  def project do
    [
      aliases: aliases(),
      apps_path: "apps",
      build_embedded: Mix.env == :prod,
      deps: deps(),
      preferred_cli_env: ["coveralls": :test, "coveralls.detail": :test, "coveralls.post": :test, "coveralls.html": :test],
      start_permanent: Mix.env == :prod,
      test_coverage: [tool: ExCoveralls]
    ]
  end

  defp deps do
    []
  end

  defp aliases do
    ["test": ["ecto.drop --quiet MIX_ENV=test",
              "ecto.create --quiet MIX_ENV=test",
              "ecto.migrate --quiet MIX_ENV=test",
              "test"]]
  end
end

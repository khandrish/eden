defmodule Mix.Tasks.Exmud.Setup do
  use Mix.Task

  @shortdoc "Perform all initial setup work, such as setting up databases. Should only need to be run once."

  @doc false
  def run(_) do
    IO.puts "Creating databases"
    Mix.Task.run "execs.setup"
    IO.puts "Finished creating databases"
  end
end

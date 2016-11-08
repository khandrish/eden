defmodule Mix.Tasks.Exmud.Teardown do
  use Mix.Task

  @shortdoc "Perform all initial teardown work, such as removing databases. Make sure to have backups."

  @doc false
  def run(_) do
    IO.puts "Deleting databases"
    Mix.Task.run "execs.teardown"
    IO.puts "Finished deleting databases"
  end
end

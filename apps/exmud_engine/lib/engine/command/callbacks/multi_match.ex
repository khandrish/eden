defmodule Exmud.Engine.Command.MultiMatch do
  @moduledoc """
  This system Command is invoked when multiple matches have been made while processing an input string.

  The multiple matches are saved on the calling Object and a new Command Set is added which allows the player to select which Command they which to execute, or to cancel the whole process.

  Finally, a message is sent to the player alerting them of the error and the choices provided to them by the new Commands added to the Object they are puppeting.
  """

  use Exmud.Engine.Command

  @impl
  def doc_generation, do: false

  @impl
  def execute(execution_context) do
    # Save multiple commands to calling object, probably via new component/attribute to be used by multi
    # Add a dynamically generated command set to the calling Object with Commands that will allow triggering of saved/matched commands
    # Send message to player warning of multiple match error and detailing commands that are now available

    #     No, should be a single hardcoded command set and dynamically generated message to the player that outlines the various options that can be taken. It should be a very high priority command set that replaces all others (in almost every case) containing a single command which matches any number passed to it and which pulls the previously saved commands out of the DB and selects the correct one to execute.
    #     If the number doesn't match, leave the command set in place. If it does match remove command set, and then remove component/data from caller

    # retrieve multimatch data
    # match number argument against the

    execution_context
  end

  @impl
  def key, do: "CMD_MULTI_MATCH"
end

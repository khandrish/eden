defmodule Exmud.Command.Processor.Default do
  @behaviour Exmud.Command.Processor

  @str "get the shiny red ring from in the pouch in the backpack on the second shelf in the third alcove"

  @prepositions [
                  "from",
                  "in",
                  "on",
                  "under",
                  "around",
                  "near",
                  "through"
                ]

  @articles ["a", "the"]


  #
  # Callbacks
  #


  def parse(subject, command_string) do
    [verb, command_string] =
      if String.contains?(command_string, " ") do
        String.split(@command_string, " ", parts: 2)
      else
        [command_string, ""]
      end

    # get command context, the set of object which can have their commands callable by subject
    # get command sets and merge them together to get set of commands to check against
    # match verb to command
    # if command_string is not empty
    #   get syntax for arguments from command
    #   parse string into data structure that can be parsed to transform specific types of properties


    # get syntax for verb, and use that to determine what to do with the command string, such as whether or not any processing is necessary
    syntax = %{properties: [%{key: "direct_object", optional: false, positional: true, type: :noun}, %{key: "indirect_object", optional: true, positional: true, type: :noun}], switches: ["carefully", "cautiously", "slowly", "quickly"]}

    parse_string(command_string, :noun)
  end


  #
  # Private Functions
  #

  # if noun is only property, noun will be last thing OTHER than prepositional phrases
  defp parse_string(command_string, :noun) do

  end
end
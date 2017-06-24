defmodule Exmud.Object.Template do
  @moduledoc """
  An Object Template defines all of the components, command sets, scripts, locks, and custom callbacks that make up a
  single object.

  Rather than be
  """

  @typedoc "The id of the object being created."
  @type oid :: term

  @typedoc "Arguments passed to the spawner along with the template. If no arguments are passed, nil is used instead."
  @type args :: term | nil


  @doc """
  Run the transformer on the passed in command string.

  The intention is that these preprocessors should be able to be mixed and matched transparently to each other, to the
  engine, and to the command callback module which will eventually process the command string. To that effect, this
  callback function takes in a string and returns a string.

  An example use case would be for universal command aliases, where a `'` prefix might be transformed into the string
  `say ` so the engine can match the correct command. For example, the player might enter `'Hello world!` which would
  likely not match any command registered. To make sure the input is mapped to the correct command, a transformer might
  spit out the string `say Hello world!` which would then match against a `say` command. This helps keep the command
  matching logic simple as it only has to match full words.
  """
  @callback define(oid, args) :: term
end

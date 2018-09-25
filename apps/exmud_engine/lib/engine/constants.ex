defmodule Exmud.Engine.Constants do
  @moduledoc """
  A set of functions returning static values to help avoid hardcoding values throughout the code.
  """

  def command_execution_success, do: "success"

  def command_execution_failure, do: "failure"

  def command_set_visibility_internal, do: "internal"

  def command_set_visibility_external, do: "external"

  def command_set_visibility_both, do: "both"

  def command_doc_merge_type_union, do: "union"

  def command_doc_category_general, do: "General"

  def system_command_prefix, do: ~r/^CMD_/

  def command_multi_match_key, do: "multi_match_commands"

  def system_registry, do: :exmud_engine_system_registry
  def script_registry, do: :exmud_engine_script_registry
  def player_registry, do: :exmud_engine_player_registry



  #
  #
  # Tags
  #
  #

  def engine_tag_category, do: "__ENGINE__"
  def player_tag, do: "player"
  def character_tag, do: "character"


  #
  #
  # Attribute Names
  #
  #

  def player_name_attribute, do: "player_name"
end

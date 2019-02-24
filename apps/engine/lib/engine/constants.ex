defmodule Exmud.Engine.Constants do
  @moduledoc """
  A set of functions returning static values to help avoid hardcoding values throughout the code.
  """

  @spec command_execution_success() :: String.t()
  def command_execution_success, do: "success"

  @spec command_execution_failure() :: String.t()
  def command_execution_failure, do: "failure"

  @spec command_set_visibility_internal() :: String.t()
  def command_set_visibility_internal, do: "internal"

  @spec command_set_visibility_external() :: String.t()
  def command_set_visibility_external, do: "external"

  @spec command_set_visibility_both() :: String.t()
  def command_set_visibility_both, do: "both"

  @spec command_doc_merge_type_union() :: String.t()
  def command_doc_merge_type_union, do: "union"

  @spec command_doc_category_general() :: String.t()
  def command_doc_category_general, do: "General"

  @spec system_command_prefix() :: Regex.t()
  def system_command_prefix, do: ~r/^CMD_/

  @spec command_multi_match_key() :: String.t()
  def command_multi_match_key, do: "multi_match_commands"

  @spec system_registry() :: :engine_system_registry
  def system_registry, do: :engine_system_registry
  @spec script_registry() :: :engine_script_registry
  def script_registry, do: :engine_script_registry
  @spec player_registry() :: :engine_player_registry
  def player_registry, do: :engine_player_registry

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

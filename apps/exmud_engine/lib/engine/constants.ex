defmodule Exmud.Engine.Constants do
  def command_execution_success do
    "success"
  end

  def command_execution_failure do
    "failure"
  end

  def command_set_visibility_internal do
    "internal"
  end

  def command_set_visibility_external do
    "external"
  end

  def command_set_visibility_both do
    "both"
  end

  def command_doc_merge_type_union do
    "union"
  end

  def command_doc_category_general do
    "General"
  end

  def system_command_prefix do
    ~r/^CMD_/
  end

  def command_multi_match_key do
    "multi_match_commands"
  end
end

defmodule Exmud.Engine.Constants do
  defmacro command_execution_success do
    quote do: "success"
  end

  defmacro command_execution_failure do
    quote do: "failure"
  end

  defmacro command_set_visibility_internal do
    quote do: "internal"
  end

  defmacro command_set_visibility_external do
    quote do: "external"
  end

  defmacro command_set_visibility_both do
    quote do: "both"
  end

  defmacro command_doc_merge_type_union do
    quote do: "union"
  end

  defmacro command_doc_category_general do
    quote do: "General"
  end

  defmacro system_command_prefix do
    quote do: ~r/^CMD_/
  end

  defmacro command_multi_match_key do
    quote do: "multi_match_commands"
  end
end

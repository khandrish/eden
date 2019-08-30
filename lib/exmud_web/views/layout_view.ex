defmodule ExmudWeb.LayoutView do
  use ExmudWeb, :view

  def map_flash_key_to_callout_class("info"), do: "primary"
  def map_flash_key_to_callout_class("warning"), do: "warning"
  def map_flash_key_to_callout_class("error"), do: "error"
  def map_flash_key_to_callout_class("success"), do: "success"
end

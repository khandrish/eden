defmodule Exmud.Game.SchemaHelpers do

  def callback(key, callback_function) do
    %{key: key, callback_function: callback_function}
  end

  def command_set(key, callback_module) do
    %{key: key, callback_module: callback_module}
  end

  def component(key, callback_module) do
    %{key: key, callback_module: callback_module}
  end

  def script(key, callback_module, options \\ @default_script_options) do
    options = Keyword.merge(options, @default_script_options)
    %{callback_module: callback_module, key: key, options: options}
  end

  def system(key, callback_module, options \\ @default_system_options) do
    options = Keyword.merge(options, @default_system_options)
    %{callback_module: callback_module, key: key, options: options}
  end
end
defmodule Exmud.Engine.Template do
  @moduledoc """
  A Template is what describes an object for the Spawner.
  """

  defstruct command_sets: [],
            command_sets_done: false,
            components: [],
            components_done: false,
            links: [],
            links_done: false,
            locks: [],
            locks_done: false,
            scripts: [],
            scripts_done: false,
            tags: [],
            tags_done: false

  #
  # Behavior definition and default callback setup
  #

  @callback command_sets(term()) ::
              {:ok, [Exmud.Engine.Template.CommandSetEntry.t()]} | {:error, atom()}
  @callback components(term()) ::
              {:ok, [Exmud.Engine.Template.ComponentEntry.t()]} | {:error, atom()}
  @callback links(term()) ::
              {:ok, [Exmud.Engine.Template.LinkEntry.t()]} | {:error, atom()}
  @callback locks(term()) ::
              {:ok, [Exmud.Engine.Template.LockEntry.t()]} | {:error, atom()}
  @callback scripts(term()) ::
              {:ok, [Exmud.Engine.Template.ScriptEntry.t()]} | {:error, atom()}
  @callback tags(term()) ::
              {:ok, [Exmud.Engine.Template.TagEntry.t()]} | {:error, atom()}

  @doc false
  defmacro __using__(_) do
    quote location: :keep do
      @behaviour Exmud.Engine.Template
      alias Exmud.Engine.Template.CommandSetEntry
      alias Exmud.Engine.Template.ComponentEntry
      alias Exmud.Engine.Template.LinkEntry
      alias Exmud.Engine.Template.LockEntry
      alias Exmud.Engine.Template.ScriptEntry
      alias Exmud.Engine.Template.TagEntry
      import Exmud.Engine.Constants

      @doc false
      def command_sets(_config), do: []

      @doc false
      def components(_config), do: []

      @doc false
      def links(_config), do: []

      @doc false
      def locks(_config), do: []

      @doc false
      def scripts(_config), do: []

      @doc false
      def tags(_config), do: []

      defoverridable command_sets: 1,
                     components: 1,
                     links: 1,
                     locks: 1,
                     scripts: 1,
                     tags: 1
    end
  end

  @spec build_template(module(), any()) :: Exmud.Engine.Template.t()
  def build_template(callback_module, config) do
    %Exmud.Engine.Template{
      command_sets: callback_module.command_sets(config),
      components: callback_module.components(config),
      links: callback_module.links(config),
      locks: callback_module.locks(config),
      scripts: callback_module.scripts(config),
      tags: callback_module.tags(config)
    }
  end
end

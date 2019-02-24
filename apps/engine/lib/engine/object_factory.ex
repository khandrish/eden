defmodule Exmud.Engine.ObjectFactory do
  @moduledoc """
  Generates Objects from Template modules
  """

  alias Exmud.Engine.CommandSet
  alias Exmud.Engine.Component
  alias Exmud.Engine.Link
  alias Exmud.Engine.Lock
  alias Exmud.Engine.Object
  alias Exmud.Engine.Script
  alias Exmud.Engine.Tag
  alias Exmud.Engine.Template
  import Exmud.Engine.Utils

  @doc """
  Takes in a module which implements the 'Exmud.Engine.Template' behaviour and constructs a Game Object.

  On successful return of the function, a new Game Object will have been created and saved into the DB. Scripts attached
  to an Object are also started immediately. They don't have to remain active but that is up to the logic of the
  individual Script. Just know that they will be started.
  """
  @spec generate(module(), term()) :: :ok
  def generate(template, config) do
    generate(Object.new!(), template, config)
  end

  @spec generate(object_id :: integer(), module(), term()) :: :ok
  # Here because of Component.attach/3 below
  @dialyzer {:no_return, generate: 3}
  defp generate(object_id, template_module, config) when is_integer(object_id) do
    # Creating a Game Object from a template should be an atomic operation
    template = Template.build_template(template_module, config)

    Enum.each(template.command_sets, fn command_set ->
      :ok = CommandSet.attach(object_id, command_set.callback_module, command_set.config)
    end)

    Enum.each(template.components, fn component ->
      :ok = Component.attach(object_id, component.callback_module, component.config)
    end)

    Enum.each(template.links, fn link ->
      :ok = Link.forge(link.to, link.type, link.config)
    end)

    Enum.each(template.locks, fn lock ->
      :ok = Lock.lock(object_id, lock.access_type, lock.callback_module, lock.config)
    end)

    Enum.each(template.tags, fn tag ->
      :ok = Tag.attach(object_id, tag.category, tag.tag)
    end)

    Enum.each(template.scripts, fn script ->
      :ok = Script.attach(object_id, script.callback_module, script.config)
      :ok = Script.start(object_id, script.callback_module, script.config)
    end)

    :ok
  end
end

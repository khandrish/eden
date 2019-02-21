defmodule Exmud.Engine.ObjectFactory do
  @moduledoc """
  The Spawner takes in a Template and constructs a Game Object.

  On successful return of the function, a new Game Object will have been created and saved into the DB as an atomic
  action. Scripts attached to an Object are also started immediately. They don't have to remain active but that is up to
  the logic of the individual Script. Just know that they will be started.
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
  Creates a new Object while spawning a Template. See `spawn/4`.
  """
  @spec generate( %Template{}, term() ) :: :ok
  def generate( %Template{} = template, config ) do
    spawn( Object.new!(), template, config )
  end

  @doc """
  Spawning an Object from a Template is an atomic operation, where everything is constructed correctly or nothing is.
  """
  @spec generate( object_id :: integer(), %Template{}, term() ) :: :ok
  def generate( object_id, %Template{} = template, config ) when is_integer( object_id)  do
    # Creating a Game Object from a template should be an atomic operation
    wrap_callback_in_retryable_transaction( fn ->
        template = Template.build_template( template, config )

        Enum.each( template.command_sets, fn command_set ->
          :ok = CommandSet.attach( object_id, command_set.callback_module, command_set.config )
        end )

        Enum.each( template.components, fn component ->
          :ok = Component.attach( object_id, component.callback_module, component.config )
        end )

        Enum.each( template.links, fn link ->
          :ok = Link.forge( link.to, link.type, link.config )
        end )

        Enum.each( template.locks, fn lock ->
          :ok = Lock.attach( object_id, lock.access_type, lock.callback_module, lock.config )
        end )

        Enum.each( template.tags, fn tag ->
          :ok = Tag.attach( object_id, tag.category, tag.tag )
        end )

        Enum.each( template.scripts, fn script ->
          :ok = Script.attach( object_id, script.callback_module, script.config )
          :ok = Script.start( object_id, script.callback_module, script.config )
        end )
    end )

    :ok
  end
end

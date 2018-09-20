defmodule Exmud.Engine.Spawner do
  @moduledoc """
  The Spawner takes in a Template and constructs a Game Object.
  """

  alias Exmud.Engine.CommandSet
  alias Exmud.Engine.Component
  alias Exmud.Engine.Link
  alias Exmud.Engine.Lock
  alias Exmud.Engine.Object
  alias Exmud.Engine.Repo
  alias Exmud.Engine.Tag
  alias Exmud.Engine.Template
  import Exmud.Common.Utils

  def spawn( template, config ) when is_atom( template ) and is_map( config ) do
    # Creating a Game Object from a template should be an atomic operation
    Repo.transaction( fn ->
      # Callback modules will be called which could have bugs
      try do
        object_id = Object.new!()
        template = Template.build_template( template, object_id, config )

        process_template( template, object_id, config )
      rescue
        _ ->
        Repo.rollback( :unhandled_exception )
      end
    end )
    |> normalize_repo_result()
  end

  defp process_template( %Template{ command_sets: [], command_sets_done: false } = template, object_id, config ) do
    process_template( %{ template | command_sets_done: true }, object_id, config )
  end

  defp process_template( %Template{ command_sets: [ command_set | rest ] } = template, object_id, config ) do
    :ok = CommandSet.attach( object_id, command_set.callback_module, command_set.config )
    process_template( %{ template | command_sets: rest }, object_id, config )
  end

  defp process_template( %Template{ components: [], components_done: false } = template, object_id, config ) do
    process_template( %{ template | components_done: true }, object_id, config )
  end

  defp process_template( %Template{ components: [ component | rest ] } = template, object_id, config ) do
    :ok = Component.attach( object_id, component.callback_module, component.config )
    process_template( %{ template | components: rest }, object_id, config )
  end

  defp process_template( %Template{ links: [], links_done: false } = template, object_id, config ) do
    process_template( %{ template | links_done: true }, object_id, config )
  end

  defp process_template( %Template{ links: [ link | rest ] } = template, object_id, config ) do
    :ok = Link.forge( link.to, link.type, link.state )
    process_template( %{ template | links: rest }, object_id, config )
  end

  defp process_template( %Template{ locks: [], locks_done: false } = template, object_id, config ) do
    process_template( %{ template | locks_done: true }, object_id, config )
  end

  defp process_template( %Template{ locks: [ lock | rest ] } = template, object_id, config ) do
    :ok = Lock.attach( object_id, lock.access_type, lock.callback_module, lock.config )
    process_template( %{ template | locks: rest }, object_id, config )
  end

  defp process_template( %Template{ tags: [], tags_done: false } = template, object_id, config ) do
    process_template( %{ template | tags_done: true }, object_id, config )
  end

  defp process_template( %Template{ tags: [ tag | rest ] } = template, object_id, config ) do
    :ok = Tag.attach( object_id, tag.category, tag.tag )
    process_template( %{ template | tags: rest }, object_id, config )
  end

  defp process_template( %Template{ scripts: [], scripts_done: false } = template, object_id, config ) do
    process_template( %{ template | scripts_done: true }, object_id, config )
  end

  defp process_template( %Template{ scripts: [ script | rest ] } = template, object_id, config ) do
    :ok = Script.start( object_id, script.callback_module, script.config )
    process_template( %{ template | scripts: rest }, object_id, config )
  end

  defp process_template( _template, _object_id, _config ) do
    :ok
  end
end

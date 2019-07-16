defmodule Exmud.Engine.Component do
  @moduledoc """
  Components act both as flags, indicating that an Object has some set of properties, and as containers for attributes
  that are in some way related. They complement Tags and should be used when a simple boolean value is not enough.

  For example, a character Component might hold information about the account it belongs to, relationships to other
  characters, aliases, skillpoints, and so on.

  Each Component added to an Object should be populated with the expected fields and values required for game logic to
  successfully interact with the Object. If there is zero data associated with a Component a Tag might be more
  appropriate.
  """

  alias Exmud.Engine.Object
  alias Exmud.Engine.Repo
  alias Exmud.Engine.Schema.Component
  import Ecto.Query
  require Logger

  #
  # Types and default callbacks
  #

  @typedoc "The Object being populated with the Component and its data."
  @type object_id :: integer()

  @typedoc "Configuration passed through to a callback module."
  @type config :: term()

  @typedoc "An error returned when something has gone wrong."
  @type error :: atom()

  @typedoc "The callback_module that is the implementation of the Component logic."
  @type callback_module :: module()

  @typedoc "A callback module which implements the 'Exmud.Engine.Component' behavior."
  @type component :: module()

  @doc """
  Called when a Component has been added to an Object. Is responsible for populating the Component with the necessary
  data.
  """
  @callback init(config) :: :ok : {:error, error}

  #
  # API
  #

  @doc """
  Atomically attach a Component to an Object and populate it with attributes using the provided, optional, args.
  """
  @spec attach(object_id, component, config | nil) ::
          :ok
          | {:error, :no_such_object}
          | {:error, :already_attached}
          | {:error, :callback_failed}
          | {:error, error}
  # No way for Dialyzer to determine that passed in Component module should implement 'populate/2' callback above
  @dialyzer {:nowarn_function, attach: 3}
  @dialyzer {:no_return, attach: 2}
  def attach(object_id, component, config \\ nil) do
    record =
      Component.new(%{
        callback_module: component,
        data: component.init(config),
        object_id: object_id
      })

    Object.attach(record)
  end

  @doc """
  See 'all_attached?/2'.
  """
  @spec attached?(object_id, component) :: boolean
  def attached?(object_id, component) do
    all_attached?(object_id, component)
  end

  @doc """
  Check to see if a given Component, or list of components, is attached to an Object. Will only return `true` if all
  provided values are matched.
  """
  @spec all_attached?(object_id, component | [component]) :: boolean
  def all_attached?(object_id, components) do
    components = List.wrap(components)
    query = get_count_query(object_id, components)

    Repo.one(query) == length(components)
  end

  @doc """
  Check to see if a given Component, or list of components, is attached to an Object. Will return `true` if any of the
  provided values are matched.
  """
  @spec any_attached?(object_id, component | [component]) :: boolean
  def any_attached?(object_id, components) do
    components = List.wrap(components)
    query = get_count_query(object_id, components)

    Repo.one(query) > 0
  end

  defp get_count_query(object_id, components) do
    components = List.wrap(components)
    count_query(object_id, components)
  end

  @doc """
  Detach all Components, deleting all associated data, attached to a given Object or set of Objects.
  """
  @spec detach(object_id | [object_id]) :: :ok
  def detach(object_ids) do
    delete_query =
      from(component in Component, where: component.object_id in ^List.wrap(object_ids))

    Repo.delete_all(delete_query)

    :ok
  end

  @doc """
  Detach one or more Components, deleting all associated data, attached to a given Object.
  """
  @spec detach(object_id | [object_id], component | [component]) :: :ok
  def detach(object_ids, components) do
    components = List.wrap(components)
    object_ids = List.wrap(object_ids)
    delete_query = component_query(object_ids, components)

    Repo.delete_all(delete_query)

    :ok
  end

  @spec component_query([object_id], [component]) :: term
  defp component_query(object_ids, components) do
    from(
      component in Component,
      where: component.callback_module in ^components and component.object_id in ^object_ids
    )
  end

  @spec count_query(object_id, [component]) :: term
  defp count_query(object_id, components) do
    from(
      component in component_query(object_id, components),
      select: count("*")
    )
  end
end

defmodule Exmud.Engine.Attribute do
  @moduledoc """
  An `Exmud.Component` can have an arbitrary number of attributes associated with it.

  Attributes are where all of the actual values within the engine is stored, and all Attributes belong to a Component
  which has been attached to an Object.
  """

  alias Ecto.Multi
  alias Exmud.Engine.Repo
  alias Exmud.Engine.Schema.Attribute
  import Ecto.Query
  import Exmud.Common.Utils
  require Logger

  #
  # Typespecs
  #

  @typedoc """
  The id of an Object on which all operations are to take place.
  """
  @type object_id :: integer

  @typedoc """
  The callback module which implements the Component behavior
  """
  @type component :: module

  @typedoc """
  The key of the Attribute on which all operations are to take place.
  """
  @type attribute_name :: String.t()

  @typedoc """
  The value belonging to an Attribute.
  """
  @type value :: term

  @typedoc """
  A function used to compare values for equality.
  """
  @type comparison_fun :: term

  @typedoc """
  An error which happened during an operation.
  """
  @type error :: term

  #
  # API
  #

  @doc """
  Remove an Attribute from a Component.
  """
  @spec delete(object_id, component, attribute_name) :: :ok | {:error, :no_such_attribute}
  def delete(object_id, component, attribute_name) do
    component = pack_term(component)

    attribute_query(object_id, component, attribute_name)
    |> Repo.delete_all()
    |> case do
      {1, _} -> :ok
      {0, _} -> {:error, :no_such_attribute}
      _ -> {:error, :unknown}
    end
  end

  @doc """
  Returns whether or not the specified Attribute is present on the Component and equal to the provided value.

  When called with anything other than a function as the last argument, a simple in database equality check is
  performed. If an anonymous function, arity of one, is passed in the Attribute valuewill be retrieved from the database
  and passed into the function. The function must return a boolean value that indicates whether or not the data matches.

  Since the comparison is done client side using the method in this way is less efficient but more powerful as there is
  complete control over checking an arbitrarily complex data structure.
  """
  @spec equals?(object_id, component, attribute_name, comparison_fun | value) :: boolean
  def equals?(object_id, component, attribute_name, comparison_fun)
      when is_function(comparison_fun) do
    case read(object_id, component, attribute_name) do
      {:ok, attribute_value} ->
        comparison_fun.(attribute_value)

      _ ->
        false
    end
  end

  def equals?(object_id, component, attribute_name, value) do
    component = pack_term(component)

    query =
      from(
        attribute in attribute_query(object_id, component, attribute_name),
        where: attribute.value == ^pack_term(value),
        select: count("*")
      )

    Repo.one(query) == 1
  end

  @doc """
  Returns whether or not the specified Attribute is present on the Component.

  Will return `false` if the Object/Component does not exist instead of an error.
  """
  @spec exists?(object_id, component, attribute_name) :: boolean
  def exists?(object_id, component, attribute_name) when is_integer(object_id) do
    component = pack_term(component)

    query =
      from(
        component in attribute_query(object_id, component, attribute_name),
        select: count("*")
      )

    Repo.one(query) == 1
  end

  @doc """
  Returns whether or not the specified value is present on any Object.

  Will return `false` if the Component does not exist instead of an error.
  """
  @spec exists?(component, attribute_name, comparison_fun | value) :: boolean
  def exists?(component, attribute_name, comparison_fun) when is_function(comparison_fun) do
    component = pack_term(component)

    query =
      from(
        attribute in Attribute,
        inner_join: comp in assoc(attribute, :component),
        where:
          attribute.name == ^attribute_name and
            comp.callback_module == ^component,
        select: attribute.value
      )

    Repo.all(query)
    |> Enum.any?(fn value ->
      comparison_fun.(value)
    end)
  end

  def exists?(component, attribute_name, value) do
    component = pack_term(component)

    query =
      from(
        attribute in Attribute,
        inner_join: comp in assoc(attribute, :component),
        where:
          attribute.name == ^attribute_name and
            comp.callback_module == ^component and
            attribute.value == ^pack_term(value),
        select: count("*")
      )

    Repo.one(query) >= 1
  end

  @doc """
  Put an Attribute value into a Component.

  This is a destructive write that does not check for the presence of existing Attribute values. Will return an error
  if the Object/Component does not exist. The error will be ':no_such_component' in either case as a seperate check to
  determine if it's the Object or just the Component that is missing is not performed.
  """
  @spec put(object_id, component, attribute_name, value) :: :ok | {:error, :no_such_component}
  def put(object_id, component, attribute_name, value) do
    packed_component = pack_term(component)

    query =
      from(
        comp in Exmud.Engine.Schema.Component,
        where: comp.object_id == ^object_id and comp.callback_module == ^packed_component
      )

    case Repo.one(query) do
      nil ->
        {:error, :no_such_component}

      component ->
        new_attribute_params = %{name: attribute_name, value: pack_term(value)}
        assoc = Ecto.build_assoc(component, :attributes, new_attribute_params)

        Multi.new()
        |> Multi.delete_all(
          :delete_existing_attribute,
          attribute_query(object_id, packed_component, attribute_name)
        )
        |> Multi.insert(:insert_new_attribute, assoc)
        |> Repo.transaction()

        :ok
    end
  end

  @doc """
  Read the value of an Attribute.
  """
  @spec read(object_id, component, attribute_name) :: {:ok, value} | {:error, :no_such_attribute}
  def read(object_id, component, attribute_name) do
    component = pack_term(component)

    case Repo.one(attribute_query(object_id, component, attribute_name)) do
      nil -> {:error, :no_such_attribute}
      attribute_value -> {:ok, unpack_term(attribute_value.value)}
    end
  end

  @doc """
  Update an Attribute.
  """
  @spec update(object_id, component, attribute_name, value) :: :ok | {:error, :no_such_attribute}
  def update(object_id, component, attribute_name, value) do
    component = pack_term(component)

    query =
      from(
        attribute in attribute_query(object_id, component, attribute_name),
        update: [set: [value: ^pack_term(value)]]
      )

    case Repo.update_all(query, []) do
      {1, _} -> :ok
      {0, _} -> {:error, :no_such_attribute}
    end
  end

  #
  # Private functions
  #

  @spec attribute_query(object_id, component, attribute_name) :: term
  defp attribute_query(object_id, component, attribute_name) do
    from(
      attribute in Attribute,
      inner_join: comp in assoc(attribute, :component),
      where:
        attribute.name == ^attribute_name and
          comp.callback_module == ^component and
          comp.object_id == ^object_id
    )
  end
end

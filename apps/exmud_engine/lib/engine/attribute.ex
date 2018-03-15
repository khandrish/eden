defmodule Exmud.Engine.Attribute do
  @moduledoc """
  An `Exmud.Component` can have an arbitrary number of attributes associated with it.

  Attributes are where all of the actual data within the engine is stored, and all Attributes belong to a Component
  which has been attached to an Object.
  """

  alias Exmud.Engine.Component
  alias Exmud.Engine.Repo
  alias Exmud.Engine.Schema.Attribute
  import Ecto.Query
  import Exmud.Common.Utils
  import Exmud.Engine.Utils
  require Logger


  #
  # Typespecs
  #

  @typedoc """
  The id of an Object on which all operations are to take place.
  """
  @type object_id :: integer

  @typedoc """
  The Component on which all operations are to take place.
  """
  @type component :: String.t

  @typedoc """
  The Attribute on which all operations are to take place.
  """
  @type attribute :: String.t

  @typedoc """
  The data belonging to an Attribute.
  """
  @type data :: term

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
  @spec delete(object_id, component, attribute) :: :ok | {:error, :no_such_attribute}
  def delete(object_id, component, attribute) do
    attribute_query(object_id, component, attribute)
    |> Repo.delete_all()
    |> case do
      {1, _} -> :ok
      {0, _} -> {:error, :no_such_attribute}
      _ -> {:error, :unknown}
    end
  end

  @doc """
  Returns whether or not the specified Attribute is present on the Component and equal to the provided value.

  Will return `false` if the Object/Component/Attribute do not exist instead of an error. Performs a simple equality
  check in the database itself rather than client side.
  """
  @spec equals?(object_id, component, attribute, data) :: boolean
  def equals?(object_id, component, attribute, data) do
    query =
      from attribute in attribute_query(object_id, component, attribute),
        where: attribute.data == ^pack_term(data),
        select: count("*")

    Repo.one(query) == 1
  end

  @doc """
  Returns whether or not the specified Attribute is present on the Component and equal to the provided value.

  As it takes in a function with which to compare the two values the Attribute must be present and populated in the
  database otherwise an error will be returned. Since the comparison is done client side this call is less efficient
  than `equals?/4` but is obviously more flexible.

  The passed in function is expected to take two arguments, the first being the Attribute data and the second being the
  value passed to the `equals?/5` function, and must return a boolean value.
  """
  @spec equals(object_id, component, attribute, data, comparison_fun) :: {:ok, boolean} | {:error, :no_such_attribute}
  def equals(object_id, component, attribute, data_to_compare, fun) do
    case read(object_id, component, attribute) do
      {:ok, attribute_data} ->
        {:ok, fun.(attribute_data, data_to_compare)}
      error ->
        error
    end
  end

  @doc """
  Returns whether or not the specified Attribute is present on the Component.

  Will return `false` if the Object/Component does not exist instead of an error.
  """
  @spec exists?(object_id, component, attribute) :: boolean
  def exists?(object_id, component, attribute) do
    query =
      from component in attribute_query(object_id, component, attribute),
        select: count("*")

    Repo.one(query) == 1
  end

  @doc """
  Put an Attribute value into a Component.

  This is a destructive write that does not check for the presence of existing Attribute values. Will return an error
  if the Object/Component does not exist, however.
  """
  @spec put(object_id, component, attribute, data) :: :ok | {:error, error}
  def put(object_id, component, attribute, data) do
    case Component.get(object_id, component) do
      {:ok, comp} ->
        args = %{data: pack_term(data),
                 attribute: attribute}

        Ecto.build_assoc(comp, :attributes, args)
        |> Repo.insert()
        |> normalize_repo_result()
      error ->
        error
    end
  end

  @doc """
  Read the value of an Attribute.
  """
  @spec read(object_id, component, attribute) :: {:ok, data} | {:error, :no_such_attribute}
  def read(object_id, component, attribute) do
    case Repo.one(attribute_query(object_id, component, attribute)) do
      nil -> {:error, :no_such_attribute}
      attribute_data -> {:ok, unpack_term(attribute_data.data)}
    end
  end

  @doc """
  Update a Component.
  """
  @spec update(object_id, component, attribute, data) :: :ok | {:error, :no_such_attribute}
  def update(object_id, component, attribute, data) do
    query =
      from attribute in attribute_query(object_id, component, attribute),
        update: [set: [data: ^pack_term(data)]]

    case Repo.update_all(query, []) do
      {1, _} -> :ok
      {0, _} -> {:error, :no_such_attribute}
    end
  end


  #
  # Private functions
  #


  defp attribute_query(object_id, component_name, attribute) do
    from attribute in Attribute,
      inner_join: component in assoc(attribute, :component),
      where: attribute.attribute == ^attribute
        and component.name == ^component_name
        and component.object_id == ^object_id
  end
end
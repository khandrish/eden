defmodule Exmud.Engine.Link do
  @moduledoc """
  A `Exmud.Engine.Link` is a one-way relationship between two Objects that describes their connection.

  Unlike Scripts, Systems, and Components, Links are lightweight in that they don't require any callback modules or
  prior registration with the Engine to forge a link between two Objects.

  While Links can have data associated with them, it is not required. A Link could represent a simple parent/child
  relationship which is effectively boolean and requires no additional data, or it could represent two Objects which
  are exists? in combat which are a certain distance from the other which must be tracked.
  """

  alias Ecto.Multi
  alias Exmud.Engine.Repo
  alias Exmud.Engine.Schema.Link
  import Exmud.Common.Utils
  import Exmud.Engine.Utils
  import Ecto.Query


  #
  # Typespecs
  #


  @typedoc """
  The Object id that is the originator of the link.
  """
  @type from :: object_id

  @typedoc """
  The Object id that is the destination of the link.
  """
  @type to :: object_id

  @typedoc """
  The type of link that connects two Objects.
  """
  @type type :: String.t

  @typedoc """
  The data associated with a Link
  """
  @type data :: term

  @typedoc """
  The id of an Object.
  """
  @type object_id :: integer

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
  Break all Links to or from an Object.
  """
  @spec break_all(object_id) :: :ok | {:error, :no_such_link}
  def break_all(object_id) do
    query =
      from link in Link,
        where: link.from_id == ^object_id
          or link.to_id == ^object_id

    query
    |> Repo.delete_all()
    |> validate_break_result()
  end

  @doc """
  Break all Links between two Objects.
  """
  @spec break_all(object_id, object_id) :: :ok | {:error, :no_such_link}
  def break_all(object_id1, object_id2) do
    query =
      from link in Link,
        where: link.from_id == ^object_id1 and link.to_id == ^object_id2,
        or_where: link.from_id == ^object_id2 and link.to_id == ^object_id1

    query
    |> Repo.delete_all()
    |> validate_break_result()
  end

  @doc """
  Break all Links of a specific type between two Objects.

  Note that order does not matter, as all links of the specified type will be broken in both directions.
  """
  @spec break_all(object_id, object_id, type) :: :ok | {:error, :no_such_link}
  def break_all(object_id1, object_id2, link_type) do
    query = link_omnidirectional_query(object_id1, object_id2, link_type)

    query
    |> Repo.delete_all()
    |> validate_break_result()
  end

  @doc """
  Break all Links of a specific type that matches a specific criteria between two Objects.

  When called with anything other than a function as the last argument, a simple in database equality check is
  performed. If an anonymous function, arity of one, is passed in the Link data will be retrieved from the database to
  be passed into the function.

  If a function is passed in the Link must be present and populated in the database otherwise an error will be returned.
  Since the comparison is done client side using the method in this way is less efficient but more powerful as there is
  complete control over checking an arbitrarily complex data structure.
  """
  @spec break_all(object_id, object_id, type, comparison_fun | data) :: :ok
                                                                      | {:error, :no_such_link}
                                                                      | {:error, :unable_to_break_links}
  def break_all(object_id1, object_id2, link_type, comparison_fun) when is_function(comparison_fun) do
    query = link_directional_query(object_id1, object_id2, link_type)

    links_to_break =
      query
      |> Repo.all()
      |> Stream.map(&({&1.id, unpack_term(&1.data)}))
      |> Enum.filter(&(comparison_fun.(elem(&1, 1))))

    if length(links_to_break) > 0 do
      links_to_break
      |> Enum.reduce(Multi.new(), &(Multi.delete(&2, UUID.uuid4(), %Link{id: elem(&1, 0)})))
      |> Repo.transaction()
      |> case do
        {:ok, _} -> :ok
        _ -> {:error, :unable_to_break_links}
      end
    else
      {:error, :no_such_link}
    end
  end

  def break_all(object_id1, object_id2, link_type, data) do
    query = link_omnidirectional_query(object_id1, object_id2, link_type, data)

    query
    |> Repo.delete_all()
    |> validate_break_result()
  end

  @doc """
  Break a specific Link between two Objects.

  Note that the order of the object id's does matter as this method only breaks a single directional link.
  """
  @spec break_one(from, to, type) :: :ok | {:error, :no_such_link}
  def break_one(from, to, type) do
    link_directional_query(from, to, type)
    |> Repo.delete_all()
    |> validate_break_result()
  end

  @doc """
  Link two Objects together, providing a type string that describes the link along with some optional data which can be
  used to define the link itself.
  """
  @spec forge(from, to, type, data) :: :ok | {:error, term}
  def forge(from, to, type, data \\ nil) do
    %Link{}
    |> Link.new(%{from_id: from, to_id: to, type: type, data: pack_term(data)})
    |> Repo.insert()
    |> case do
      {:ok, _} -> :ok
      _ -> {:error, :unable_to_forge_link}
    end
  end

  @doc """
  Link two Objects together bidirectionally, providing a type string that describes the link along with some optional
  data which can be used to define the link itself.

  Two seperate links will be created with the same type and same data, each one pointing in the opposite direction.
  """
  @spec forge_both(object_id, object_id, type, data) :: :ok | {:error, :unable_to_forge_link}
  def forge_both(object_id1, object_id2, type, data \\ nil) do
    paked_data = pack_term(data)
    links =
      [
        [
          from_id: object_id1,
          to_id: object_id2,
          type: type,
          data: paked_data
        ],
        [
          from_id: object_id2,
          to_id: object_id1,
          type: type,
          data: paked_data
        ]
      ]

    Repo.transaction(fn ->
      case Repo.insert_all(Link, links) do
        {2, _} ->
          :ok
        _ ->
          Repo.rollback(:unable_to_forge_link)
      end
    end)
    |> normalize_repo_result()
  end

  @doc """
  Returns a boolean indicating whether or not the two objects are linked in any way.

  Note that the order of the object id's does not matter. Any matching link in any direction will return true.
  """
  @spec any_exist?(object_id, object_id) :: boolean
  def any_exist?(object_id1, object_id2) do
    query = link_count_query(object_id1, object_id2)

    Repo.one(query) > 0
  end

  @doc """
  Returns a boolean indicating whether or not the two objects are linked by a specific type.

  Note that the order of the object id's does not matter. Any matching link in any direction will return true.
  """
  @spec any_exist?(object_id, object_id, type) :: boolean
  def any_exist?(object_id1, object_id2, type) do
    query = link_count_query(object_id1, object_id2, type)

    Repo.one(query) > 0
  end

  @doc """
  Returns a boolean indicating whether or not the two objects are linked by a specific type.

  Note that the order of the object id's does not matter. Any matching link in any direction will return true.

  When called with anything other than a function as the last argument, a simple in database equality check is
  performed. If an anonymous function, arity of one, is passed in the Link data will be retrieved from the database to
  be passed into the function. The function must return a boolean value that indicates whether or not the data matches.

  Since the comparison is done client side using the method in this way is less efficient but more powerful as there is
  complete control over checking an arbitrarily complex data structure.
  """
  @spec any_exist?(object_id, object_id, type, comparison_fun | data) :: boolean
  def any_exist?(object_id1, object_id2, type, comparison_fun) when is_function(comparison_fun) do
    query = link_omnidirectional_query(object_id1, object_id2, type)

    Repo.all(query)
    |> Stream.map(&(unpack_term(&1.data)))
    |> Enum.filter(comparison_fun)
    |> length() > 0
  end

  def any_exist?(object_id1, object_id2, type, data) do
    query = link_count_query(object_id1, object_id2, type, data)

    Repo.one(query) > 0
  end

  @doc """
  Returns a boolean indicating whether or not the two objects are linked.

  Note that the order of the object id's does matter. Only links originating from the first Object are checked.
  """
  @spec exists?(from, to) :: boolean
  def exists?(from, to) do
    query =
      from link in link_directional_query(from, to),
        select: count("*")

    Repo.one(query) > 0
  end

  @doc """
  Returns a boolean indicating whether or not the two objects are linked by a specified type of link.

  Note that the order of the object id's does matter. Only links originating from the first Object are checked.
  """
  @spec exists?(from, to, type) :: boolean
  def exists?(from, to, type) do
    query =
      from link in link_directional_query(from, to, type),
        select: count("*")

    Repo.one(query) == 1
  end

  @doc """
  Returns a boolean indicating whether or not the two objects are linked by a specified type of link with data to match.

  Note that the order of the object id's does matter. Only links originating from the first Object are checked.

  When called with anything other than a function as the last argument, a simple in database equality check is
  performed. If an anonymous function, arity of one, is passed in the Link data will be retrieved from the database to
  be passed into the function. The function must return a boolean value that indicates whether or not the data matches.

  Since the comparison is done client side using the method in this way is less efficient but more powerful as there is
  complete control over checking an arbitrarily complex data structure.
  """
  @spec exists?(from, to, type, comparison_fun | data) :: boolean
  def exists?(from, to, type, comparison_fun) when is_function(comparison_fun) do
    case Repo.one(link_directional_query(from, to, type)) do
      nil -> false
      link -> comparison_fun.(unpack_term(link.data))
    end
  end

  def exists?(from, to, type, data) do
    query =
      from link in link_directional_query(from, to, type, data),
        select: count("*")

    Repo.one(query) == 1
  end

  @doc """
  Update the data associated with a Link between two Objects.

  Note that the order of the object id's does matter. Only links originating from the first Object are updated.
  """
  @spec update(from, to, type, data) :: :ok | {:error, :no_such_link}
  def update(from, to, type, data) do
    link_directional_query(from, to, type)
    |> Repo.update_all(set: [data: pack_term(data)])
    |> case do
      {0, _} -> {:error, :no_such_link}
      _ -> :ok
    end
  end

  @doc """
  Update the data associated with a Link between two Objects.

  Note that the order of the object id's does not matter. All links between the two Objects that match the type are
  updated.
  """
  @spec update_all(object_id, object_id, type, data) :: :ok | {:error, :no_such_link}
  def update_all(object_id1, object_id2, type, data) do
    link_omnidirectional_query(object_id1, object_id2, type)
    |> Repo.update_all(set: [data: pack_term(data)])
    |> case do
      {0, _} -> {:error, :no_such_link}
      _ -> :ok
    end
  end


  #
  # Private functions
  #


  @spec link_directional_query(from, to) :: term
  defp link_directional_query(object_id1, object_id2) do
    from link in Link,
      where: link.from_id == ^object_id1
         and link.to_id == ^object_id2
  end

  @spec link_directional_query(from, to, type) :: term
  defp link_directional_query(object_id1, object_id2, type) do
    from link in Link,
      where: link.from_id == ^object_id1
         and link.to_id == ^object_id2
         and link.type == ^type
  end

  @spec link_directional_query(from, to, type, data) :: term
  defp link_directional_query(object_id1, object_id2, type, data) do
    from link in Link,
      where: link.from_id == ^object_id1
         and link.to_id == ^object_id2
         and link.type == ^type
         and link.data == ^pack_term(data)
  end

  @spec link_omnidirectional_query(object_id, object_id) :: term
  defp link_omnidirectional_query(object_id1, object_id2) do
    from link in Link,
      where: link.from_id == ^object_id1
         and link.to_id == ^object_id2,
      or_where: link.from_id == ^object_id2
            and link.to_id == ^object_id1
  end

  @spec link_omnidirectional_query(object_id, object_id, type) :: term
  defp link_omnidirectional_query(object_id1, object_id2, type) do
    from link in Link,
      where: link.from_id == ^object_id1
         and link.to_id == ^object_id2
         and link.type == ^type,
      or_where: link.from_id == ^object_id2
            and link.to_id == ^object_id1
            and link.type == ^type
  end

  @spec link_omnidirectional_query(object_id, object_id, type, data) :: term
  defp link_omnidirectional_query(object_id1, object_id2, type, data) do
    from link in Link,
      where: link.from_id == ^object_id1
         and link.to_id == ^object_id2
         and link.type == ^type
         and link.data == ^pack_term(data),
      or_where: link.from_id == ^object_id2
            and link.to_id == ^object_id1
            and link.type == ^type
            and link.data == ^pack_term(data)
  end

  defp link_count_query(object_id1, object_id2) do
    from link in link_omnidirectional_query(object_id1, object_id2),
      select: count("*")
  end

  defp link_count_query(object_id1, object_id2, type) do
    from link in link_omnidirectional_query(object_id1, object_id2, type),
      select: count("*")
  end

  defp link_count_query(object_id1, object_id2, type, data) do
    from link in link_omnidirectional_query(object_id1, object_id2, type, data),
      select: count("*")
  end

  defp validate_break_result({0, _}), do: {:error, :no_such_link}
  defp validate_break_result({_some_positive_number, _}), do: :ok
end
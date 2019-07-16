defmodule Exmud.Engine.Link do
  @moduledoc """
  A `Exmud.Engine.LinkModel` is a one-way relationship between two Objects that describes their connection.

  Unlike Scripts, Systems, and Components, Links are lightweight in that they don't require any callback modules to
  forge a link between two Objects.

  While Links can have state associated with them, it is not required. A Link could represent a simple parent/child
  relationship which is effectively boolean and requires no additional state, or it could represent two Objects which
  are in combat which are a certain distance from the other which must be tracked.
  """

  alias Ecto.Multi
  alias Exmud.DB
  alias Exmud.DB.Link
  alias Exmud.DB.LinkModel
  alias Exmud.Engine.Repo
  import Exmud.Common.Utils
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
  @type type :: String.t()

  @typedoc """
  The state associated with a Link
  """
  @type state :: term

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
    query = from(link in LinkModel, where: link.from_id == ^object_id or link.to_id == ^object_id)

    query
    |> DB.()
    |> validate_break_result()
  end

  @doc """
  Break all Links between two Objects.
  """
  @spec break_all(object_id, object_id) :: :ok | {:error, :no_such_link}
  def break_all(object_id1, object_id2) do
    query =
      from(
        link in LinkModel,
        where: link.from_id == ^object_id1 and link.to_id == ^object_id2,
        or_where: link.from_id == ^object_id2 and link.to_id == ^object_id1
      )

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
  performed. If an anonymous function, arity of one, is passed in the Link state will be retrieved from the database to
  be passed into the function.

  If a function is passed in the Link must be present and populated in the database otherwise an error will be returned.
  Since the comparison is done client side using the method in this way is less efficient but more powerful as there is
  complete control over checking an arbitrarily complex state structure.
  """
  @spec break_all(object_id, object_id, type, comparison_fun | state) ::
          :ok
          | {:error, :no_such_link}
          | {:error, :unable_to_break_links}
  def break_all(object_id1, object_id2, link_type, comparison_fun)
      when is_function(comparison_fun) do
    query = link_directional_query(object_id1, object_id2, link_type)

    links_to_break =
      query
      |> Repo.all()
      |> Stream.map(&{&1.id, &1.state})
      |> Enum.filter(&comparison_fun.(elem(&1, 1)))

    if length(links_to_break) > 0 do
      links_to_break
      |> Enum.reduce(Multi.new(), &Multi.delete(&2, UUID.uuid4(), %LinkModel{id: elem(&1, 0)}))
      |> Repo.transaction()
      |> case do
        {:ok, _} -> :ok
        _ -> {:error, :unable_to_break_links}
      end
    else
      {:error, :no_such_link}
    end
  end

  def break_all(object_id1, object_id2, link_type, state) do
    query = link_omnidirectional_query(object_id1, object_id2, link_type, state)

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
  Link two Objects together, providing a type string that describes the link along with some optional state which can be
  used to define the link itself.
  """
  @spec forge(from, to, type, state) :: :ok | {:error, term}
  def forge(from, to, type, state \\ nil) do
    Link.new(%{from_id: from, to_id: to, type: type, state: state})
    |> Repo.insert()
    |> case do
      {:ok, _} -> :ok
      _ -> {:error, :unable_to_forge_link}
    end
  end

  @doc """
  Link two Objects together bidirectionally, providing a type string that describes the link along with some optional
  state which can be used to define the link itself.

  Two seperate links will be created with the same type and same state, each one pointing in the opposite direction.
  """
  @spec forge_both(object_id, object_id, type, state) :: :ok
  def forge_both(object_id1, object_id2, type, state \\ nil) do
    paked_data = state

    links = [
      [
        from_id: object_id1,
        to_id: object_id2,
        type: type,
        state: paked_data
      ],
      [
        from_id: object_id2,
        to_id: object_id1,
        type: type,
        state: paked_data
      ]
    ]

    {2, _} = Repo.insert_all(LinkModel, links)

    :ok
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
  performed. If an anonymous function, arity of one, is passed in the Link state will be retrieved from the database to
  be passed into the function. The function must return a boolean value that indicates whether or not the state matches.

  Since the comparison is done client side using the method in this way is less efficient but more powerful as there is
  complete control over checking an arbitrarily complex state structure.
  """
  @spec any_exist?(object_id, object_id, type, comparison_fun | state) :: boolean
  def any_exist?(object_id1, object_id2, type, comparison_fun) when is_function(comparison_fun) do
    query = link_omnidirectional_query(object_id1, object_id2, type)

    Repo.all(query)
    |> Stream.map(& &1.state)
    |> Enum.filter(comparison_fun)
    |> length() > 0
  end

  def any_exist?(object_id1, object_id2, type, state) do
    query = link_count_query(object_id1, object_id2, type, state)

    Repo.one(query) > 0
  end

  @doc """
  Returns a boolean indicating whether or not the two objects are linked.

  Note that the order of the object id's does matter. Only links originating from the first Object are checked.
  """
  @spec exists?(from, to) :: boolean
  def exists?(from, to) do
    query = from(link in link_directional_query(from, to), select: count("*"))

    Repo.one(query) > 0
  end

  @doc """
  Returns a boolean indicating whether or not the two objects are linked by a specified type of link.

  Note that the order of the object id's does matter. Only links originating from the first Object are checked.
  """
  @spec exists?(from, to, type) :: boolean
  def exists?(from, to, type) do
    query = from(link in link_directional_query(from, to, type), select: count("*"))

    Repo.one(query) == 1
  end

  @doc """
  Returns a boolean indicating whether or not the two objects are linked by a specified type of link with state to
  match.

  Note that the order of the object id's does matter. Only links originating from the first Object are checked.

  When called with anything other than a function as the last argument, a simple in database equality check is
  performed. If an anonymous function, arity of one, is passed in the Link state will be retrieved from the database to
  be passed into the function. The function must return a boolean value that indicates whether or not the state matches.

  Since the comparison is done client side using the method in this way is less efficient but more powerful as there is
  complete control over checking an arbitrarily complex state structure.
  """
  @spec exists?(from, to, type, comparison_fun | state) :: boolean
  def exists?(from, to, type, comparison_fun) when is_function(comparison_fun) do
    case Repo.one(link_directional_query(from, to, type)) do
      nil -> false
      link -> comparison_fun.(link.state)
    end
  end

  def exists?(from, to, type, state) do
    query = from(link in link_directional_query(from, to, type, state), select: count("*"))

    Repo.one(query) == 1
  end

  @doc """
  Update the state associated with a Link between two Objects.

  Note that the order of the object id's does matter. Only links originating from the first Object are updated.
  """
  @spec update(from, to, type, state) :: :ok | {:error, :no_such_link}
  def update(from, to, type, state) do
    link_directional_query(from, to, type)
    |> Repo.update_all(set: [state: state])
    |> case do
      {0, _} -> {:error, :no_such_link}
      _ -> :ok
    end
  end

  @doc """
  Update the state associated with a Link between two Objects.

  Note that the order of the object id's does not matter. All links between the two Objects that match the type are
  updated.
  """
  @spec update_all(object_id, object_id, type, state) :: :ok | {:error, :no_such_link}
  def update_all(object_id1, object_id2, type, state) do
    link_omnidirectional_query(object_id1, object_id2, type)
    |> Repo.update_all(set: [state: state])
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
    from(link in LinkModel, where: link.from_id == ^object_id1 and link.to_id == ^object_id2)
  end

  @spec link_directional_query(from, to, type) :: term
  defp link_directional_query(object_id1, object_id2, type) do
    from(
      link in LinkModel,
      where: link.from_id == ^object_id1 and link.to_id == ^object_id2 and link.type == ^type
    )
  end

  @spec link_directional_query(from, to, type, state) :: term
  defp link_directional_query(object_id1, object_id2, type, state) do
    from(
      link in LinkModel,
      where:
        link.from_id == ^object_id1 and link.to_id == ^object_id2 and link.type == ^type and
          link.state == ^state
    )
  end

  @spec link_omnidirectional_query(object_id, object_id) :: term
  defp link_omnidirectional_query(object_id1, object_id2) do
    from(
      link in LinkModel,
      where: link.from_id == ^object_id1 and link.to_id == ^object_id2,
      or_where: link.from_id == ^object_id2 and link.to_id == ^object_id1
    )
  end

  @spec link_omnidirectional_query(object_id, object_id, type) :: term
  defp link_omnidirectional_query(object_id1, object_id2, type) do
    from(
      link in LinkModel,
      where: link.from_id == ^object_id1 and link.to_id == ^object_id2 and link.type == ^type,
      or_where: link.from_id == ^object_id2 and link.to_id == ^object_id1 and link.type == ^type
    )
  end

  @spec link_omnidirectional_query(object_id, object_id, type, state) :: term
  defp link_omnidirectional_query(object_id1, object_id2, type, state) do
    from(
      link in LinkModel,
      where:
        link.from_id == ^object_id1 and link.to_id == ^object_id2 and link.type == ^type and
          link.state == ^state,
      or_where:
        link.from_id == ^object_id2 and link.to_id == ^object_id1 and link.type == ^type and
          link.state == ^state
    )
  end

  @spec link_count_query(object_id, object_id) :: term
  defp link_count_query(object_id1, object_id2) do
    from(link in link_omnidirectional_query(object_id1, object_id2), select: count("*"))
  end

  @spec link_count_query(object_id, object_id, type) :: term
  defp link_count_query(object_id1, object_id2, type) do
    from(link in link_omnidirectional_query(object_id1, object_id2, type), select: count("*"))
  end

  @spec link_count_query(object_id, object_id, type, state) :: term
  defp link_count_query(object_id1, object_id2, type, state) do
    from(
      link in link_omnidirectional_query(object_id1, object_id2, type, state),
      select: count("*")
    )
  end

  @spec validate_break_result({number :: integer, state :: term}) :: :ok | {:error, :no_such_link}
  defp validate_break_result({0, _}), do: {:error, :no_such_link}
  defp validate_break_result({_some_positive_number, _}), do: :ok
end

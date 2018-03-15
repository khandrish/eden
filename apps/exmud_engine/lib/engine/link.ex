defmodule Exmud.Engine.Link do
  @moduledoc """
  A `Exmud.Link` is a relationship between two Objects that describes their connection.

  Unlike Scripts, Systems, and Components, Links are lightweight in that they don't require any callback modules or
  prior registration with the Engine to forge a link between two Objects.

  While Links can have data associated with them, it is not required. A Link could represent a simple parent/child
  relationship which is effectively boolean and requires no additional data, or it could represent two Objects which
  are linked in combat which are a certain distance from the other which must be tracked.
  """

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
  @type from :: integer

  @typedoc """
  The Object id that is the target of the link.
  """
  @type to :: String.t

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
  @type object_id :: term

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
  Break a specific link between two Objects.
  """
  @spec break(from, to, type) :: :ok | {:error, :no_such_link}
  def break(from, to, type) do
    link_query(from, to, type)
    |> Repo.delete_all()
    |> case do
      {1, _} -> :ok
      {0, _} -> {:error, :no_such_link}
    end
  end

  @doc """
  Link two Objects together, providing a type string that describes the link along with some optional data which can be
  used to define the link itself.
  """
  @spec forge(from, to, type, data) :: :ok | {:error, term}
  def forge(from, to, type, data \\ %{}) do
    %Link{}
    |> Link.new(%{from_id: from, to_id: to, type: type, data: pack_term(data)})
    |> Repo.insert()
    |> normalize_repo_result(from)
    |> case do
      {:ok, _} -> :ok
      error -> error
    end
  end

  @doc """
  Returns a boolean indicating whether or not the two objects are linked.
  """
  @spec linked?(from, to) :: boolean
  def linked?(from, to) do
    query =
      from link in link_query(from, to),
        select: count("*")

    Repo.one(query) == 1
  end

  @doc """
  Returns a boolean indicating whether or not the two objects are linked by a specified type of link.
  """
  @spec linked?(from, to, type) :: boolean
  def linked?(from, to, type) do
    query =
      from link in link_query(from, to, type),
        select: count("*")

    Repo.one(query) == 1
  end

  @doc """
  Returns a boolean indicating whether or not the two objects are linked by a specified type of link with data to match.

  Note that this is a simple equality check for the data. If a more robust method is needed examine the `linked/5`
  method.
  """
  @spec linked?(from, to, type, data) :: boolean
  def linked?(from, to, type, data) do
    query =
      from link in link_query(from, to, type, data),
        select: count("*")

    Repo.one(query) == 1
  end

  @doc """
  Returns a boolean indicating whether or not the two objects are linked by a specified type of link with data to match.

  As it takes in a function with which to compare the two values the Link must be present and populated in the
  database otherwise an error will be returned. Since the comparison is done client side this call is less efficient
  than `linked?/4` but is obviously more flexible.

  The passed in function is expected to take two arguments, the first being the Link data and the second being the
  value passed to the `linked/5` function, and must return a boolean value.
  """
  @spec linked(from, to, type, data, comparison_fun) :: {:ok, data} | {:error, :no_such_link}
  def linked(from, to, type, data, comparison_fun) do
    case Repo.one(link_query(from, to, type, data)) do
      nil -> {:error, :no_such_link}
      link ->
        {:ok, comparison_fun.(unpack_term(link.data), data)}
    end
  end


  #
  # Private functions
  #


  defp link_query(from_id, to_id) do
    from link in Link,
      where: link.from_id == ^from_id
        and link.to_id == ^to_id
  end

  defp link_query(from_id, to_id, type) do
    from link in Link,
      where: link.from_id == ^from_id
        and link.to_id == ^to_id
        and link.type == ^type
  end

  defp link_query(from_id, to_id, type, data) do
    from link in Link,
      where: link.from_id == ^from_id
        and link.to_id == ^to_id
        and link.type == ^type
        and link.data == ^pack_term(data)
  end
end
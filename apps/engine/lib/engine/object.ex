defmodule Exmud.Engine.Object do
  @moduledoc """
  An Object is a representation of 'something' within the Engine.

  It could be a Player Character, a System, an NPC, a rock, a sword, or anything really. It doesn't have to be anything
  physical. Simply something that requires some sort of representation as a distinct 'thing' within the Engine.
  """

  alias Exmud.DB
  alias Exmud.DB.Object
  alias Exmud.Engine.Repo
  import Ecto.Query
  require Logger

  defstruct command_sets: MapSet.new(),
            components: MapSet.new(),
            locks: MapSet.new(),
            links: MapSet.new(),
            scripts: MapSet.new(),
            tags: MapSet.new()

  #
  # Typespecs
  #

  @typedoc """
  The id of an Object on which all operations are to take place.
  """
  @type object_id :: integer

  @typedoc """
  The Object is the basic building block of the Engine. Almost all data in the Engine is contained in an Object.
  """
  @type object :: term

  @typedoc """
  An error which happened during an operation.
  """
  @type error :: term

  @typedoc """
  Filters for specifing which data on an Object to load
  """
  @type inclusion_filters :: [
          :command_sets | :components | :locks | :links | :scripts | :tags
        ]

  @typedoc """
  A query to be used for finding populations of Objects.
  """
  @type object_query :: term

  #
  # API
  #

  @doc """
  Atomically attach a record to an Object and optionally call a callback function on success.

  Callback function must return `:ok` or `{:error, error}` where error is an atom to be used for pattern matching.

  Should an exception be raused during the callback, the transaction will rollback and the response
  `{:error, :callback_failed}` will be returned.
  """
  @spec attach(record, callback_function) ::
          :ok
          | {:error, :no_such_object | :already_attached | :callback_failed}
  def attach(record, callback_function \\ nil) do
    record
    |> Repo.insert()
    |> normalize_repo_result()
    |> case do
      :ok ->
        if is_function(callback_function) do
          try do
            :ok = callback_function.()
          rescue
            _ -> {:error, :callback_failed}
          end
        else
          :ok
        end

      {:error, [object_id: _error]} ->
        {:error, :no_such_object}

      {:error, [{_, "has already been taken"}]} = _ ->
        {:error, :already_attached}
    end
  end

  @doc """
  Create a new Object.
  """
  @spec new! :: object_id
  def new! do
    DB.insert!(Exmud.DB.Object.new())
  end

  @doc """
  Delete an Object.
  """
  @spec delete(object_id | Object.t()) ::
          :ok | {:error, :no_such_object} | {:error, Ecto.Changeset.t()}
  def delete(object = %Object{}) do
    case Repo.delete(object) do
      {:ok, _} -> :ok
      error -> error
    end
  end

  def delete(object_id) do
    case Repo.delete(%Object{id: object_id}) do
      {:ok, _} -> :ok
      error -> error
    end
  end

  @doc """
  Get an Object by its id.

  Returns an Object preloaded with all data.
  """
  @spec get(object_id) :: {:ok, object} | {:error, :invalid_object_id}
  def get(object_id) do
    query =
      from(
        object in Object,
        where: object.id == ^object_id,
        preload: [:command_sets, :components, :links, :locks, :scripts, :tags]
      )

    case Repo.one(query) do
      nil ->
        {:error, :invalid_object_id}

      object ->
        object = normalize_objects(object) |> List.first()
        {:ok, object}
    end
  end

  @doc """
  Query the Engine for Objects based on the passed in where clause.

  Using Ecto's dynamic/2 method, a where clause should be created that will return the desired Objects. The returned
  Objects will have all their data preloaded.

  All relations are bound in alphabetical order: [:command_sets, :components, :links, :locks, :scripts, :tags]
  """
  @spec query(object_query) :: [object]
  def query(where_clause) do
    query =
      from(
        object in Object,
        left_join: command_set in assoc(object, :command_sets),
        left_join: component in assoc(object, :components),
        left_join: link in assoc(object, :links),
        left_join: lock in assoc(object, :locks),
        left_join: script in assoc(object, :scripts),
        left_join: tag in assoc(object, :tags),
        where: ^where_clause,
        preload: [:command_sets, :components, :links, :locks, :scripts, :tags]
      )

    Repo.all(query)
    |> normalize_objects()
  end

  #
  # Private functions
  #

  defp normalize_objects(objects) do
    objects
    |> List.wrap()
    |> Enum.map(fn object ->
      %{
        object
        | command_sets:
            Enum.map(object.command_sets, fn command_set ->
              %{
                command_set
                | callback_module: String.to_existing_atom(command_set.callback_module)
              }
            end),
          components:
            Enum.map(object.components, fn component ->
              %{component | callback_module: String.to_existing_atom(component.callback_module)}
            end),
          locks:
            Enum.map(object.locks, fn lock ->
              %{lock | callback_module: String.to_existing_atom(lock.callback_module)}
            end),
          scripts:
            Enum.map(object.scripts, fn script ->
              %{script | callback_module: String.to_existing_atom(script.callback_module)}
            end)
      }
    end)
  end
end

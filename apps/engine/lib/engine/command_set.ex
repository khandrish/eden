defmodule Exmud.Engine.CommandSet do
  @moduledoc """
  Command Sets represent a group of Commands.

  Command Sets not only allow Commands to be added to/removed from Objects in bulk, but they define the rules by which
  multiple Command Sets can be merged to present a final unified set of Commands for further processing.
  """

  defstruct [
    :merge_set
  ]

  @doc false
  defmacro __using__(_) do
    quote location: :keep do
      @behaviour Exmud.Engine.CommandSet
      import Exmud.Engine.Constants

      @doc false
      @impl true
      def name( _config ), do: Atom.to_string( __MODULE__ )

      @doc false
      @impl true
      def commands( _config ), do: []

      @doc false
      @impl true
      def merge_priority( _config ), do: 1

      @doc false
      @impl true
      def merge_type( _config ), do: :union

      @doc false
      @impl true
      def merge_overrides( _config ), do: %{}

      @doc false
      @impl true
      def allow_duplicates( _config ), do: false

      @doc false
      @impl true
      def visibility( _config ), do: command_set_visibility_both()

      defoverridable commands: 1,
                     merge_priority: 1,
                     merge_type: 1,
                     merge_overrides: 1,
                     allow_duplicates: 1,
                     visibility: 1
    end
  end

  @doc """
  The name of the Command Set. This is a friendly name that can be used to help identify Command Sets in a UI and within the game.
  """
  @callback name( config ) :: String.t()

  @doc """
  The merge type to use when being merged, unless an override matches in which case that is used instead.
  Defaults to ':union'
  """
  @callback merge_type( config ) :: merge_type

  @doc """
  Determines whether or not to allow for duplicate Commands when merging. This defaults to 'false' but can be set to 'true' to allow for more complex behavior.
  """
  @callback allow_duplicates( config ) :: merge_type

  @doc """
  The overrides to check against when determining merge_type. If any match the name of a lower priority CommandSet, the specified merge type will be used instead of what is returned by 'merge_type/1'
  """
  @callback merge_overrides( config ) :: merge_type

  @doc """
  The list of commands that are contained in the Command Set.
  """
  @callback commands( config ) :: [ term ]

  @doc """
  The priority of the CommandSet when being merged. Default is 1.
  """
  @callback merge_priority( config ) :: integer

  @doc """
  The visibility of the Command Set. Can be one of '"internal" | "external" | "both"'. Defaults to '"both"'.
  """
  @callback visibility( config ) :: visibility

  @typedoc "Configuration passed through to a callback module."
  @type config :: term

  @typedoc "An error message passed through to the caller."
  @type error :: term

  @typedoc "Id of the Object the Command Set is attached to."
  @type object_id :: integer

  @typedoc "The name of the Command Set."
  @type name :: String.t()

  @typedoc "An Ecto query."
  @type query :: term

  @typedoc "A Command struct."
  @type command :: %Exmud.Engine.Command{}

  @typedoc "A key to be merged."
  @type key :: term

  @typedoc "The callback_module that is the implementation of the Command Set logic."
  @type callback_module :: atom

  @typedoc "One of a finite set of types of merges that can take place."
  @type merge_type :: :union | :intersect | :remove | :replace

  @typedoc "The visibility of the Command Set. Can be one of: internal, external, both."
  @type visibility :: String.t

  alias Exmud.Engine.Command
  alias Exmud.Engine.MergeSet
  alias Exmud.Engine.ObjectUtil
  alias Exmud.Engine.Schema.Object
  alias Exmud.Engine.Repo
  alias Exmud.Engine.Schema.CommandSet
  import Ecto.Query
  import Exmud.Common.Utils
  require Logger
  import Exmud.Engine.Constants

  #
  # API
  #

  @doc """
  Attach a Command Set to an Object.
  """
  @spec attach( object_id, callback_module, config ) ::
          :ok
          | { :error, :no_such_object }
          | { :error, :already_attached }
  def attach( object_id, callback_module, config \\ %{} ) when is_map( config ) do
    record =
      CommandSet.new(
        %{
          object_id: object_id,
          callback_module: pack_term( callback_module ),
          config: pack_term( config ),
          visibility: callback_module.visibility( config )
        }
      )

    ObjectUtil.attach( record )
  end

  @doc """
  Given either an '%Ecto.Query{}' struct that returns a list of Object ids, or a list of Object ids explicitly, build the list of Commands that the caller has access to.

  Given that every Command is executed in the context of a calling Object, and that Command Sets can have differing visibilities such as internal to an Object as is the case for many default Commands, a failure to include the calling Object in the context query could break an unknown number of things. Don't do it.

  ## Ecto query

  When providing an '%Ecto.Query{}' struct the query should only contain 'where' and 'join' statements.

  Example:
  '''
  context_query = from(
    object in Object,
    join: game_object_component in assoc(object, :components),
    join: game_object_location_attribute in assoc(game_object_component, :attributes),
    where: game_object_component.object_id == object.id
      and game_object_component.name == "GameObject"
      and game_object_component.id == game_object_location_attribute.component_id
      and game_object_location_attribute.key == "location"
      and game_object_location_attribute.value == ^location,
    select: object.id
  )

  build_active_command_list(caller, context_query)
  '''

  ## List

  Single values are wrapped in a list.

  Examples:
  '''
  object = 42
  build_active_command_list(object, object)
  '''
  '''
  object = 42
  context = [42, 1, 3, 5, 7, 11, 13, 17, 23, 27]
  build_active_command_list(object, context)
  '''

  The active Command list is the result of merging all Command Sets attached to a set of Objects in a determanistic order.

  All Command Sets within the context are retrieved and then sorted from oldest to newest, and then grouped by priority, and then further still within each priority group by type of merge to be performed...which is then further prioritized

  Once the Command Sets have been properly grouped and sorted and flattened they are then merged in order until a single Command Set remains.

  The list of Commands is the extracted and returned from this Command Set.
  """
  @spec build_active_command_list( object_id, query | object_id | [ object_id ] ) :: [] | [ command ]
  def build_active_command_list( caller, context ) when is_integer( context ) do
    build_active_command_list( caller, List.wrap( context ) )
  end

  def build_active_command_list( caller, context ) when is_list( context ) do
    query = from(
      object in Object,
      join: command_set in assoc( object, :command_sets ), on: object.id == command_set.object_id,
      select: { command_set.object_id, command_set.callback_module, command_set.config },
      where: object.id in ^context
        and command_set.visibility != ^command_set_visibility_internal()
        and object.id != ^caller,
      or_where: object.id in ^context
        and command_set.visibility != ^command_set_visibility_external()
        and object.id == ^caller,
      order_by: [ asc: command_set.inserted_at ]
    )

    do_build( query )
  end

  def build_active_command_list( caller, context_query ) do
    query = from(
      object in Object,
      join: obj in subquery( context_query ), on: object.id == obj.id,
      join: command_set in assoc( object, :command_sets ), on: object.id == command_set.object_id,
      select: { command_set.object_id, command_set.callback_module, command_set.config },
      where: command_set.visibility != ^command_set_visibility_internal() and object.id != ^caller,
      or_where: command_set.visibility != ^command_set_visibility_external() and object.id == ^caller,
      order_by: [ asc: command_set.inserted_at ]
    )

    do_build( query )
  end

  @spec do_build( term ) :: [] | [ command ]
  defp do_build( context_query ) do
    case Repo.all( context_query ) do
      [] ->
        []
      command_sets ->
        command_sets
        # Transform each command set from database into a merge set
        |> Enum.reduce( [], fn { object_id, callback_module, config }, list ->
          [ build_merge_set( object_id, unpack_term( callback_module ), unpack_term( config ) ) | list ]
        end)
        |> Enum.reverse()
        |> Enum.sort( fn first_merge_set, second_merge_set ->
          if first_merge_set.priority == second_merge_set.priority do
            MergeSet.sort_by_merge_type( first_merge_set, second_merge_set )
          else
            first_merge_set.priority <= second_merge_set.priority
          end
        end )
        |> Enum.reduce( nil, fn higher_priority_merge_set, lower_priority_merge_set  ->
          MergeSet.merge( higher_priority_merge_set, lower_priority_merge_set, &comparison_function/2 )
        end )
        |> ( &( &1.keys ) ).()
        |> Enum.filter( fn command ->
          Enum.all?( command.locks, fn
            { lock, config } ->
              lock.check( :command, command.object_id, config )
            lock ->
              lock.check( :command, command.object_id, nil )
          end )
        end )
    end
  end

  # Used within MergeSet when merging. In the case of a Command Set, the keys are callback modules which implement the Exmud.Engine.Command behaviour. When comparing Commands, both the key and the aliases need to be checked for conflict.
  @spec comparison_function( %Command{}, %Command{} ) :: boolean
  defp comparison_function( command_a, command_b ) do
    key_and_aliases_a = [ command_a.key | command_a.aliases ]
    key_and_aliases_b = [ command_b.key | command_b.aliases ]
    Enum.any?( key_and_aliases_a, &( &1 in key_and_aliases_b ) )
  end

  # Building a merge set means transforming the retrieved callback module/config into a Command struct.
  @spec build_merge_set( object_id, callback_module, config ) :: term
  defp build_merge_set( object_id, callback_module, config ) do
    keys =
      config
      |> callback_module.commands()
      |> Enum.map( fn command ->
        %Command{
          object_id: object_id,
          key: command.key( config ),
          execute: &command.execute/1,
          parse_args: &command.parse_args/1,
          aliases: command.aliases( config ),
          doc_generation: command.doc_generation( config ),
          doc_category: command.doc_category( config ),
          doc: get_moduledoc( command ),
          locks: command.locks( config ),
          argument_regex: command.argument_regex( config ),
          config: config
        }
      end )

    %MergeSet{
      allow_duplicates: callback_module.allow_duplicates( config ),
      keys: keys,
      name: callback_module.name( config ),
      overrides: callback_module.merge_overrides( config ),
      priority: callback_module.merge_priority( config ),
      merge_type: callback_module.merge_type( config )
    }
  end

  @doc """
  Check to see if an Object has all of the provided Command Sets attached.
  """
  @spec has_all?( object_id, callback_module | [ callback_module ] ) :: boolean
  def has_all?( object_id, command_set_callback_modules ) do
    command_set_callback_modules = List.wrap( command_set_callback_modules )

    query =
      from( command_set in command_set_query( object_id, command_set_callback_modules ), select: count( "*" ) )

    Repo.one( query ) == length( command_set_callback_modules )
  end

  @doc """
  Check to see if an Object has any of the provided Command Sets attached.
  """
  @spec has_any?( object_id, callback_module | [ callback_module ] ) :: boolean
  def has_any?( object_id, command_set_callback_modules ) do
    command_set_callback_modules = List.wrap( command_set_callback_modules )

    query =
      from( command_set in command_set_query( object_id, command_set_callback_modules ), select: count( "*" ) )

    Repo.one( query ) > 0
  end

  @doc """
  Detach one or more Command Sets from an Object.
  """
  @spec detach( object_id, callback_module | [ callback_module ] ) :: :ok
  def detach( object_id, command_set_callback_modules ) do
    command_set_callback_modules = List.wrap( command_set_callback_modules )

    command_set_query( object_id, command_set_callback_modules )
    |> Repo.delete_all()

    :ok
  end

  @spec command_set_query( object_id, [ callback_module ] ) :: term
  defp command_set_query( object_id, command_set_callback_modules ) do
    command_set_callback_modules = command_set_callback_modules |> Enum.map( &Atom.to_string/1 )

    from(
      command_set in CommandSet,
      where: command_set.callback_module in ^command_set_callback_modules and command_set.object_id == ^object_id
    )
  end
end

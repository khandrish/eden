defmodule Exmud.Engine.MergeSet do
  @moduledoc """
  A MergeSet is a set of Keys and some additional metadata configuring how two sets should be merged together.

  As in all cases of merging order does matter when merging MergeSets together, but the addition of the merge type,
  priority, and overrides impact the final product of a merge. In the case of priority, a MergeSet with a higher
  priority will take precedence over one with a lower, otherwise if two MergeSets have the same priority the first one
  will be assumed to have a higher priority.

  Once priority has been determined, the merge type from the higher priority MergeSet is selected and that merge type
  is used to perform the actual merge. If there is a merge type override in the higher priority MergeSet which matches
  the name of the lower priority MergeSet, that merge type will be used instead.

  The final MergeSet created from the merger will take all of its properties, the keys being the exception, from the
  higher priority MergeSet.

  There are four different types of merges possible:
    Union - All non-duplicate keys from both MergeSets end up in the final MergeSet. The only merge type for which
            duplicates make sense.

            Example: ["foo", "bar"] + ["foobar", "barfoo"] == ["foo", "bar", "foobar", "barfoo"]

    Intersect - Only keys which exist in both MergeSets end up in the final MergeSet. The key chosen will be from they
                higher priority MergeSet.
            Example: ["foo", "bar"] + ["foo", "foobar", "barfoo"] == ["foo"]

    Replace - The higher priority keys replace the others, no matter if keys match or not.
            Example: ["foo", "bar"] + ["foobar", "barfoo"] == ["foo", "bar"]

    Remove - The higher priority keys replace the others, however any intersecting keys are first removed from the
             higher priority MergeSet.
            Example: ["foo", "bar", "foobar"] + ["foobar", "barfoo"] == ["foo", "bar"]
  """

  @typedoc "A map holding  a set of arbitrary terms as keys and metadata describing how to merge said set."
  @type merge_set :: map()

  @typedoc "A callback function allowing for the comparison of two arbirarily complex terms. Returning `true` means the terms are equal."
  @type comparison_function :: function()

  @typedoc "A list of options used to configure the MergeSet on creation"
  @type options :: [option]

  @typedoc "An option passed to the creation method for MergeSets."
  @type option :: {key, value}

  @typedoc "One of the attributes of the MergeSet to configure on creation."
  @type key :: :allow_duplicates | :keys | :merge_type | :priority | :name

  @typedoc "The configuration value for the MergeSet."
  @type value :: term

  @typedoc "The priority for a MergeSet."
  @type priority :: integer

  @typedoc "The type of merge to perform when merging the MergeSet."
  @type merge_type :: :union | :intersect | :replace | :remove

  @typedoc "Whether or not to allow duplicate keys when merging the MergeSet."
  @type allow_duplicates :: boolean

  @typedoc "The name of the MergeSet. Primarily used to check for overrides."
  @type name :: String.t()


  #
  #
  # Merge Set struct
  #
  #

  @enforce_keys [:name, :priority]
  defstruct allow_duplicates: false, keys: [], priority: nil, merge_type: :union, name: nil, overrides: %{}
  @type t :: %Exmud.Engine.MergeSet{
    allow_duplicates: boolean,
    keys: [term],
    priority: integer,
    merge_type: merge_type,
    name: String.t(),
    overrides: Map.t()
  }


  @doc """
  Add a key to the MergeSet.
  """
  @spec add_key( merge_set, key ) :: merge_set
  def add_key( merge_set, key ) do
    %{ merge_set | keys: List.insert_at(merge_set.keys, -1, key ) }
  end

  @doc """
  Check the MergeSet to see if it already contains a key.
  """
  @spec has_key?( merge_set, key ) :: boolean
  def has_key?( merge_set, key ) do
    Enum.any?( merge_set.keys, &( &1 == key ) )
  end

  @doc """
  Check the MergeSet to see if it already contains a key.
  """
  @spec has_key?( merge_set, key, comparison_function ) :: boolean
  def has_key?( merge_set, key, comparison_function ) do
    Enum.any?( merge_set.keys, fn ms_key ->
      comparison_function.( key, ms_key )
    end )
  end

  @doc """
  Remove a key from the MergeSet
  """
  @spec remove_key( merge_set, key ) :: merge_set
  def remove_key( merge_set, key ) do
    %{ merge_set | keys: Enum.reject( merge_set.keys, &( &1 == key ) ) }
  end

  @doc """
  Add an override to the MergeSet.
  """
  @spec add_override( merge_set, name, merge_type ) :: merge_set
  def add_override( merge_set, name, merge_type ) do
    %{ merge_set | overrides: Map.put( merge_set.overrides, name, merge_type ) }
  end

  @doc """
  Remove an override to the MergeSet.
  """
  @spec remove_override( merge_set, name ) :: merge_set
  def remove_override( merge_set, name ) do
    %{ merge_set | overrides: Map.delete( merge_set.overrides, name ) }
  end

  @doc """
  Remove an override to the MergeSet.
  """
  @spec has_override?( merge_set, name ) :: boolean
  def has_override?( merge_set, name ) do
    Map.has_key?( merge_set.overrides, name )
  end

  @doc """
  Merge two MergeSets according to their priority and merge type rules. An optional comparison callback function allows
  for the checking of two arbitrarily complex values.
  """
  @spec merge( merge_set, merge_set | nil, comparison_function ) :: merge_set
  def merge( merge_set_a, merge_set_b, comparison_function \\ nil )

  def merge( merge_set_a, nil, _comparison_function ) do
    merge_set_a
  end

  def merge( merge_set_a, merge_set_b, comparison_function ) do
    sort_function = &( sort( &1.priority, &2.priority ) )

    [ higher_priority_merge_set, lower_priority_merge_set ] =
      Enum.sort( [ merge_set_a, merge_set_b ], sort_function )

    merge_type =
      if Map.has_key?(higher_priority_merge_set.overrides, lower_priority_merge_set.name) do
        higher_priority_merge_set.overrides[lower_priority_merge_set.name]
      else
        higher_priority_merge_set.merge_type
      end

    comparison_function = comparison_function || ( &( &1 == &2 ) )
    allow_duplicates = higher_priority_merge_set.allow_duplicates

    merged_keys =
      merge_keys(
        merge_type,
        higher_priority_merge_set.keys,
        lower_priority_merge_set.keys,
        comparison_function,
        allow_duplicates
      )

    %{ merge_set_a | keys: merged_keys }
  end

  @doc """
  Sort function for merge sets.

  Order, from first-to-last, is union, intersect, replace, and remove
  """
  @spec sort_by_merge_type( [ struct() ], [ struct() ] ) :: boolean
  def sort_by_merge_type( merge_set_1, merge_set_2 ) do
    case { merge_set_1, merge_set_2 } do
    { %{ merge_type: :union }, _ } -> true
    { %{ merge_type: :intersect }, %{ merge_type: :union } } -> false
    { %{ merge_type: :intersect }, _ } -> true
    { %{ merge_type: :replace }, %{ merge_type: :remove } } -> false
    { %{ merge_type: :replace }, _ } -> true
    { %{ merge_type: :remove }, %{ merge_type: :remove } } -> true
    { %{ merge_type: :remove }, _ } -> false
    end
  end

  @spec sort( priority | nil, priority | nil ) :: boolean
  defp sort( nil, nil ), do: true
  defp sort( nil, _priority_b ), do: false
  defp sort( _priority_a, nil ), do: true
  defp sort( priority_a, priority_b ), do: priority_a >= priority_b

  @spec merge_keys( key, merge_set, merge_set, comparison_function, allow_duplicates :: boolean ) ::
          [ term ]
  defp merge_keys( :union, higher_priority_keys, lower_priority_keys, _comparison_function, true ) do
    higher_priority_keys ++ lower_priority_keys
  end

  defp merge_keys( :union, higher_priority_keys, lower_priority_keys, comparison_function, false ) do
    lower_priority_keys =
      Enum.drop_while( lower_priority_keys, fn low_priority_key ->
        Enum.any?( higher_priority_keys, &comparison_function.( &1, low_priority_key ) )
      end )

    higher_priority_keys ++ lower_priority_keys
  end

  defp merge_keys( :intersect, higher_priority_keys, lower_priority_keys, comparison_function, _ ) do
    Enum.filter( higher_priority_keys, fn high_priority_key ->
      Enum.any?( lower_priority_keys, fn low_priority_key ->
        comparison_function.( high_priority_key, low_priority_key )
      end )
    end )
  end

  defp merge_keys( :remove, higher_priority_keys, lower_priority_keys, comparison_function, _ ) do
    Enum.filter( lower_priority_keys, fn low_priority_key ->
      !Enum.any?( higher_priority_keys, fn high_priority_key ->
        comparison_function.( high_priority_key, low_priority_key )
      end )
    end )
  end

  defp merge_keys( :replace, higher_priority_keys, _lower_priority_keys, _comparison_function, _ ) do
    higher_priority_keys
  end
end

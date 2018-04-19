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

  @typedoc "A callback function allowing for the comparison of two arbirarily complex terms. Returning `true` means the
  terms are equal."
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
  @type merge_type :: atom

  @typedoc "Whether or not to allow duplicate keys when merging the MergeSet."
  @type allow_duplicates :: boolean

  @typedoc "The name of the MergeSet. Primarily used to check for overrides."
  @type name :: String.t()

  @doc """
  Add a key to the MergeSet.
  """
  @spec add_key(merge_set, key) :: merge_set
  def add_key(merge_set, key) do
    %{merge_set | keys: [key | merge_set.keys]}
  end

  @doc """
  Add a key to the MergeSet.
  """
  @spec has_key?(merge_set, key) :: boolean
  def has_key?(merge_set, key) do
    Enum.any?(merge_set.keys, &(&1 == key))
  end

  @doc """
  Add a key to the MergeSet.
  """
  @spec remove_key(merge_set, key) :: merge_set
  def remove_key(merge_set, key) do
    %{merge_set | keys: Enum.filter(merge_set.keys, &(&1 != key))}
  end

  @doc """
  Add a key to the MergeSet.
  """
  @spec set_allow_duplicates(merge_set, allow_duplicates) :: merge_set
  def set_allow_duplicates(merge_set, allow_duplicates) do
    %{merge_set | allow_duplicates: allow_duplicates}
  end

  @doc """
  Add a key to the MergeSet.
  """
  @spec set_merge_type(merge_set, merge_type) :: merge_set
  def set_merge_type(merge_set, merge_type) do
    %{merge_set | merge_type: merge_type}
  end

  @doc """
  Add a key to the MergeSet.
  """
  @spec set_priority(merge_set, priority) :: merge_set
  def set_priority(merge_set, priority) do
    %{merge_set | priority: priority}
  end

  @doc """
  Add an override to the MergeSet.
  """
  @spec add_override(merge_set, name, merge_type) :: merge_set
  def add_override(merge_set, name, merge_type) do
    %{merge_set | overrides: Map.put(merge_set.overrides, name, merge_type)}
  end

  @doc """
  Remove an override to the MergeSet.
  """
  @spec remove_override(merge_set, name) :: merge_set
  def remove_override(merge_set, name) do
    %{merge_set | overrides: Map.delete(merge_set.overrides, name)}
  end

  @doc """
  Remove an override to the MergeSet.
  """
  @spec has_override?(merge_set, name) :: boolean
  def has_override?(merge_set, name) do
    Map.has_key?(merge_set.overrides, name)
  end

  @doc """
  Create a new MergeSet. Must provide a name.

  Any of the attributes given in the examples below can be set, however 'allow_duplicates' is only used when the
  'merge_type' is ':union' and ignored in all other cases.

  Will throw an ArgumentError if an incorrect primitive type is used during MergeSet creation.

  ## Examples

      iex> MergeSet.new(name: "foo")
      %{
        allow_duplicates: false,
        keys: [],
        merge_type: :union,
        priority: 1,
        name: "foo",
        overrides: %{}
      }

      iex> MergeSet.new(name: "foo", priority: 5, merge_type: :intersect)
      %{
        allow_duplicates: false,
        keys: [],
        merge_type: :intersect,
        priority: 5,
        name: "foo",
        overrides: %{}
      }

  """
  @default_options [
    allow_duplicates: false,
    keys: [],
    priority: nil,
    merge_type: :union,
    name: nil,
    overrides: %{}
  ]
  @spec new(options) :: merge_set
  def new(options \\ []) do
    Keyword.merge(@default_options, options)
    |> Map.new()
  end

  @doc """
  Merge two MergeSets according to their priority and merge type rules. An optional comparison callback function allows
  for the checking of two arbitrarily complex values.
  """
  @spec merge(merge_set, merge_set, comparison_function) :: merge_set
  def merge(merge_set_a, merge_set_b, comparison_function \\ nil) do
    sort_function = &(sort(&1.priority, &2.priority))

    [higher_priority_merge_set, lower_priority_merge_set] =
      Enum.sort([merge_set_a, merge_set_b], sort_function)

    merge_type =
      if Map.has_key?(higher_priority_merge_set.overrides, lower_priority_merge_set.name) do
        higher_priority_merge_set.overrides[lower_priority_merge_set.name]
      else
        higher_priority_merge_set.merge_type
      end

    comparison_function = comparison_function || (&(&1 == &2))
    allow_duplicates = higher_priority_merge_set.allow_duplicates

    merged_keys =
      merge_keys(
        merge_type,
        higher_priority_merge_set.keys,
        lower_priority_merge_set.keys,
        comparison_function,
        allow_duplicates
      )

    %{merge_set_a | keys: merged_keys}
  end

  @spec sort(priority | nil, priority | nil) :: boolean
  defp sort(nil, nil), do: true
  defp sort(nil, _priority_b), do: false
  defp sort(_priority_a, nil), do: true
  defp sort(priority_a, priority_b), do: priority_a < priority_b

  @spec merge_keys(key, merge_set, merge_set, comparison_function, allow_duplicates :: boolean) ::
          [term]
  defp merge_keys(:union, higher_priority_keys, lower_priority_keys, _comparison_function, true) do
    higher_priority_keys ++ lower_priority_keys
  end

  defp merge_keys(:union, higher_priority_keys, lower_priority_keys, comparison_function, false) do
    lower_priority_keys =
      Enum.drop_while(lower_priority_keys, fn low_priority_key ->
        Enum.any?(higher_priority_keys, &comparison_function.(&1, low_priority_key))
      end)

    higher_priority_keys ++ lower_priority_keys
  end

  defp merge_keys(:intersect, higher_priority_keys, lower_priority_keys, comparison_function, _) do
    Enum.filter(higher_priority_keys, fn high_priority_key ->
      Enum.any?(lower_priority_keys, fn low_priority_key ->
        comparison_function.(high_priority_key, low_priority_key)
      end)
    end)
  end

  defp merge_keys(:remove, higher_priority_keys, lower_priority_keys, comparison_function, _) do
    Enum.filter(lower_priority_keys, fn low_priority_key ->
      !Enum.any?(higher_priority_keys, fn high_priority_key ->
        comparison_function.(high_priority_key, low_priority_key)
      end)
    end)
  end

  defp merge_keys(:replace, higher_priority_keys, _lower_priority_keys, _comparison_function, _) do
    higher_priority_keys
  end
end

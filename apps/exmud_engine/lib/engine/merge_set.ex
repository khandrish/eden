defmodule Exmud.Engine.MergeSet do
  @moduledoc """
  A MergeSet is a set of Keys and some additional metadata configuring how two sets should be merged together.

  As in all cases of merging order does matter when merging MergeSets together, but the addition of the merge type and
  priority impact the final product of a merge. In the case of priority, a MergeSet with a higher priority will take
  precedence over one with a lower, otherwise if two MergeSets have the same priority the first one will be assumed to
  have a higher priority.

  Once priority has been determined, the merge type from the higher priority merge set is selected and that merge type
  is used to perform the actual merge. Except for the list of keys, the final MergeSet created from the other two will
  take all of its properties from the higher priority MergeSet.


  There are four different types of merges possible:
    Union - All non-duplicate keys from both MergeSets end up in the final MergeSet. The only merge type for which
            duplicates make sense.

            Example: ["foo", "bar"] + ["foobar", "barfoo"] == ["foo", "bar", "foobar", "barfoo"]

    Intersect - Only keys which exist in both MergeSets end up in the final MergeSet.
            Example: ["foo", "bar"] + ["foo", "foobar", "barfoo"] == ["foo"]

    Replace - The higher priority keys replace the others, no matter if keys match or not.
            Example: ["foo", "bar"] + ["foobar", "barfoo"] == ["foo", "bar"]

    Remove - The higher priority keys replace the other, however any intersecting keys are first removed.
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
  @type key :: :allow_duplicates | :keys | :merge_type | :priority

  @typedoc "The configuration value for the MergeSet."
  @type value :: term

  @doc """
  Create a new MergeSet.

  Any of the attributes given in the examples below can be set, however 'allow_duplicates' is only used when the
  'merge_type' is ':union' and ignored in all other cases.

  Will throw an ArgumentError if an incorrect primitive type is used during MergeSet creation.

  ## Examples

      iex> MergeSet.new
      %{
        allow_duplicates: false,
        keys: [],
        merge_type: :union,
        priority: 1
      }

      iex> MergeSet.new(priority: 5, merge_type: :intersect)
      %{
        allow_duplicates: false,
        keys: [],
        merge_type: :intersect,
        priority: 5
      }

  """
  @default_options [
    allow_duplicates: false,
    keys: [],
    priority: 1,
    merge_type: :union
  ]
  @spec new(options) :: merge_set
  def new(options \\ []) do
    with options <- Keyword.merge(@default_options, options),
         :ok <- validate(options) do
      Map.new(options)
    end
  end

  defp validate([]), do: :ok

  defp validate([{:allow_duplicates, value} | rest]) do
    if is_boolean(value) do
      validate(rest)
    else
      raise ArgumentError, "allow_duplicates was not of the expected type"
    end
  end

  defp validate([{:keys, value} | rest]) do
    if is_list(value) and !String.valid?(value) do
      validate(rest)
    else
      raise ArgumentError, "keys was not of the expected type"
    end
  end

  defp validate([{:priority, value} | rest]) do
    if is_integer(value) do
      validate(rest)
    else
      raise ArgumentError, "priority was not of the expected type"
    end
  end

  defp validate([{:merge_type, value} | rest]) do
    if value in [:union, :intersect, :remove, :replace] do
      validate(rest)
    else
      raise ArgumentError, "merge_type was not of the expected type"
    end
  end

  @doc """
  Merge two MergeSets according to their priority and merge type rules. An optional comparison callback function allows
  for the checking of two arbitrarily complex values.
  """
  @spec merge(merge_set, merge_set, comparison_function) :: merge_set
  def merge(merge_set_a, merge_set_b, comparison_function \\ nil) do
    sort_function = &(&1.priority >= &2.priority)

    [higher_priority_merge_set, lower_priority_merge_set] =
      Enum.sort([merge_set_a, merge_set_b], sort_function)

    merge_type = higher_priority_merge_set.merge_type
    comparison_function = comparison_function || &(&1 == &2)
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

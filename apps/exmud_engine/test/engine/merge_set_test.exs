defmodule Exmud.Engine.Test.MergeSetTest do
  alias Exmud.Engine.MergeSet
  require Logger
  use ExUnit.Case, async: true

  describe "merge set" do
    @tag merge_set: true
    test "creation" do
      assert MergeSet.new() == %{
               allow_duplicates: false,
               keys: [],
               merge_type: :union,
               priority: 1,
               name: nil,
               overrides: %{}
             }
    end

    @tag merge_set: true
    test "with modifications after create" do
      ms = MergeSet.new()
      assert MergeSet.has_key?(ms, "foo") == false
      ms = MergeSet.add_key(ms, "foo")
      assert MergeSet.has_key?(ms, "foo") == true
      ms = MergeSet.remove_key(ms, "foo")
      assert MergeSet.has_key?(ms, "foo") == false
      ms = MergeSet.set_priority(ms, 2)
      ms = MergeSet.set_merge_type(ms, :intersect)
      ms = MergeSet.set_allow_duplicates(ms, true)

      assert ms == %{
               allow_duplicates: true,
               keys: [],
               merge_type: :intersect,
               priority: 2,
               name: nil,
               overrides: %{}
             }
    end

    @tag merge_set: true
    test "creation with values" do
      assert MergeSet.new(keys: ["foo"], merge_type: :intersect) == %{
               allow_duplicates: false,
               keys: ["foo"],
               merge_type: :intersect,
               priority: 1,
               name: nil,
               overrides: %{}
             }
    end

    @tag merge_set: true
    test "with simple union" do
      ms1 = MergeSet.new(keys: ["foo"])
      ms2 = MergeSet.new(keys: ["bar"])
      ms3 = MergeSet.merge(ms1, ms2)
      assert "foo" in ms3.keys and "bar" in ms3.keys
    end

    @tag merge_set: true
    test "with simple union allowing duplicates" do
      ms1 = MergeSet.new(keys: ["foo"], allow_duplicates: true)
      ms2 = MergeSet.new(keys: ["bar", "foo"])
      ms3 = MergeSet.merge(ms1, ms2)
      assert length(ms3.keys) == 3
    end

    @tag merge_set: true
    test "with simple intersect" do
      ms1 = MergeSet.new(keys: ["foo", "foobar"], merge_type: :intersect)
      ms2 = MergeSet.new(keys: ["foobar", "bar"])
      ms3 = MergeSet.merge(ms1, ms2)
      assert length(ms3.keys) == 1
      assert "foobar" in ms3.keys
    end

    @tag merge_set: true
    test "with simple remove" do
      ms1 = MergeSet.new(keys: ["foo", "foobar"], merge_type: :remove)
      ms2 = MergeSet.new(keys: ["foo", "foobar", "bar"])
      ms3 = MergeSet.merge(ms1, ms2)
      assert length(ms3.keys) == 1
      assert "bar" in ms3.keys
    end

    @tag merge_set: true
    test "with simple replace" do
      ms1 = MergeSet.new(keys: ["foo", "foobar"], merge_type: :replace)
      ms2 = MergeSet.new(keys: ["foo", "foobar", "bar"])
      ms3 = MergeSet.merge(ms1, ms2)
      assert length(ms3.keys) == 2
      assert "foo" in ms3.keys and "foobar" in ms3.keys
    end

    @tag merge_set: true
    test "with overrides" do
      ms1 = MergeSet.new(keys: ["foo"], overrides: %{"foo" => :replace}, merge_type: :union)
      assert MergeSet.has_override?(ms1, "foo")
      assert MergeSet.has_override?(ms1, "foobar") == false
      ms1 = MergeSet.add_override(ms1, "foobar", :intersect)
      assert MergeSet.has_override?(ms1, "foobar") == true
      ms1 = MergeSet.remove_override(ms1, "foobar")
      ms2 = MergeSet.new(keys: ["bar"], name: "foo")
      ms3 = MergeSet.merge(ms1, ms2)
      assert length(ms3.keys) == 1
      assert "foo" in ms3.keys
    end
  end
end

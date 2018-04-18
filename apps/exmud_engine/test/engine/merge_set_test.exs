defmodule Exmud.Engine.Test.MergeSetTest do
  alias Exmud.Engine.Object
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
              priority: 1
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
              priority: 2
            }
    end

    @tag merge_set: true
    test "creation with values" do
      assert MergeSet.new(keys: ["foo"], merge_type: :intersect) == %{
              allow_duplicates: false,
              keys: ["foo"],
              merge_type: :intersect,
              priority: 1
            }
    end

    @tag merge_set: true
    test "raises on bad allow_duplicates value" do
      assert_raise ArgumentError, "allow_duplicates was not of the expected type", fn ->
        MergeSet.new(allow_duplicates: "foo")
      end
    end

    @tag merge_set: true
    test "raises on bad keys value" do
      assert_raise ArgumentError, "keys was not of the expected type", fn ->
        MergeSet.new(keys: "foo")
      end
    end

    @tag merge_set: true
    test "raises on bad merge_type value" do
      assert_raise ArgumentError, "merge_type was not of the expected type", fn ->
        MergeSet.new(merge_type: :ksadjlsdj)
      end
    end

    @tag merge_set: true
    test "raises on bad priority value" do
      assert_raise ArgumentError, "priority was not of the expected type", fn ->
        MergeSet.new(priority: "foo")
      end
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
  end
end

defmodule Exmud.Engine.Test.MergeSetTest do
  alias Exmud.Engine.MergeSet
  require Logger
  use ExUnit.Case, async: true

  describe "merge set" do
    test "creation" do
      assert %MergeSet{ name: "test", priority: 1, keys: [ "bar" ] } == %MergeSet{
               allow_duplicates: false,
               keys: [ "bar" ],
               merge_type: :union,
               priority: 1,
               name: "test",
               overrides: %{}
             }
    end

    test "with modifications after create" do
      ms = %MergeSet{ name: "test", priority: 2, keys: [ "bar" ] }
      assert MergeSet.has_key?( ms, "foo" ) == false
      ms = MergeSet.add_key( ms, "foo" )
      assert MergeSet.has_key?( ms, "foo" ) == true
      ms = MergeSet.remove_key( ms, "foo" )
      assert MergeSet.has_key?( ms, "foo" ) == false

      assert ms == %MergeSet{
               allow_duplicates: false,
               keys: [ "bar" ],
               merge_type: :union,
               priority: 2,
               name: "test",
               overrides: %{}
             }
    end

    test "creation with values" do
      assert %MergeSet{ name: "test", priority: 1, keys: [ "foo" ], merge_type: :intersect } == %MergeSet{
               allow_duplicates: false,
               keys: [ "foo" ],
               merge_type: :intersect,
               priority: 1,
               name: "test",
               overrides: %{}
             }
    end

    test "with simple union" do
      ms1 = %MergeSet{ name: "test", priority: 1, keys: [ "foo" ] }
      ms2 = %MergeSet{ name: "test", priority: 1, keys: [ "bar" ] }
      ms3 = MergeSet.merge( ms1, ms2 )
      assert "foo" in ms3.keys and "bar" in ms3.keys
    end

    test "with simple union allowing duplicates" do
      ms1 = %MergeSet{ name: "test", priority: 2, keys: [ "foo" ], allow_duplicates: true }
      ms2 = %MergeSet{ name: "test", priority: 1, keys: [ "bar", "foo" ] }
      ms3 = MergeSet.merge( ms1, ms2 )
      assert length( ms3.keys ) == 3
    end

    test "with simple intersect" do
      ms1 = %MergeSet{ name: "test", priority: 1, keys: [ "foo", "foobar" ], merge_type: :intersect }
      ms2 = %MergeSet{ name: "test", priority: 1, keys: [ "foobar", "bar" ] }
      ms3 = MergeSet.merge( ms1, ms2 )
      assert length( ms3.keys ) == 1
      assert "foobar" in ms3.keys
    end

    test "with simple remove" do
      ms1 = %MergeSet{ name: "test", priority: 1, keys: [ "foo", "foobar" ], merge_type: :remove }
      ms2 = %MergeSet{ name: "test", priority: 1, keys: [ "foo", "foobar", "bar" ] }
      ms3 = MergeSet.merge( ms1, ms2 )
      assert length( ms3.keys ) == 1
      assert "bar" in ms3.keys
    end

    test "with simple replace" do
      ms1 = %MergeSet{ name: "test", priority: 1, keys: [ "foo", "foobar" ], merge_type: :replace }
      ms2 = %MergeSet{ name: "test", priority: 1, keys: [ "foo", "foobar", "bar" ] }
      ms3 = MergeSet.merge( ms1, ms2 )
      assert length( ms3.keys ) == 2
      assert "foo" in ms3.keys and "foobar" in ms3.keys
    end

    test "with overrides" do
      ms1 = %MergeSet{
        name: "test",
        priority: 1,
        keys: [ "foo" ],
        overrides: %{ "foo" => :replace },
        merge_type: :union
      }
      assert MergeSet.has_override?( ms1, "foo" )
      assert MergeSet.has_override?( ms1, "foobar" ) == false
      ms1 = MergeSet.add_override( ms1, "foobar", :intersect )
      assert MergeSet.has_override?( ms1, "foobar" ) == true
      ms1 = MergeSet.remove_override( ms1, "foobar" )
      ms2 = %MergeSet{ priority: 1, keys: [ "bar" ], name: "foo" }
      ms3 = MergeSet.merge( ms1, ms2 )
      assert length( ms3.keys ) == 1
      assert "foo" in ms3.keys
    end
  end
end

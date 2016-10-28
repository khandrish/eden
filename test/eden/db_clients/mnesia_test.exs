defmodule Eden.DbClient.MnesiaTest do
  alias Eden.DbClient.Mnesia
  import Eden.DbClient.Mnesia
  require Logger
  use ExUnit.Case, async: true
  
  setup_all [:setup_mnesia]

  describe "delete tests:" do
    setup [:setup_context]

    test "delete empty entity", %{id: id} = _context do
      assert transaction(fn -> delete([id]) end) == [{id, %{}}]
    end

    test "delete nonempty entity", %{id: id} = _context do
      assert transaction(fn -> write([id], [:foo], [:bar], :foobar) end) == :ok
      
      assert transaction(fn ->
        delete([id])
      end) == [{id, %{foo: %{bar: :foobar}}}]
    end

    test "delete single component", %{id: id} = _context do
      transaction(fn ->
        write([id], [:foo, :bar], [:foo, :bar], :foobar)
      end)
      
      assert transaction(fn ->
        delete([id], [:bar])
      end) == [{id, %{bar: %{foo: :foobar, bar: :foobar}}}]

      assert transaction(fn ->
        read([id])
      end) == [{id, %{foo: %{bar: :foobar, foo: :foobar}}}]
    end

    test "delete single key", %{id: id} = _context do
      transaction(fn ->
        write([id], [:foo, :bar], [:foo, :bar], :foobar)
      end)
      
      assert transaction(fn ->
        delete([id], [:bar], [:foo])
      end) == [{id, %{bar: %{foo: :foobar}}}]

      assert transaction(fn ->
        read([id])
      end) == [{id, %{foo: %{bar: :foobar, foo: :foobar}, bar: %{bar: :foobar}}}]
    end
  end

  describe "has* tests:" do
    setup [:setup_context]

    test "has_all", %{id: id} = _context do
      id2 = new_entity()

      transaction(fn ->
        write([id, id2], [:foo, :bar], [:foo, :bar], :foobar)
        write([id], [:foobar], [:foo], :foobar)
      end)

      assert transaction(fn -> 
        has_all([id], [:bar])
      end) == [{id, true}]

      assert transaction(fn -> 
        has_all([id], [:bar, :foo])
      end) == [{id, true}]

      assert transaction(fn -> 
        has_all([id, id2], [:bar, :foo])
      end) == [{id, true}, {id2, true}]

      assert transaction(fn -> 
        has_all([id, id2], [:bar, :foo, :foobar])
      end) == [{id, true}, {id2, false}]

      assert transaction(fn -> 
        has_all([id, id2], [:bar, :foo, :foobar], [:foo, :bar, :foobar])
      end) == [{id, false}, {id2, false}]

      assert transaction(fn -> 
        has_all([id, id2], [:bar, :foo], [:foo, :bar])
      end) == [{id, true}, {id2, true}]

      assert transaction(fn -> 
        has_all([id, id2],
                [:bar, :foo],
                [:foo, :bar],
                [&(&1 === :foobar), fn(_) -> true end])
      end) == [{id, true}, {id2, true}]

      assert transaction(fn -> 
        has_all([id, id2],
                [:bar, :foo],
                [:foo, :bar],
                [&(&1 === :foobar), fn(_) -> false end])
      end) == [{id, false}, {id2, false}]
    end

    test "has_any", %{id: id} = _context do
      id2 = new_entity()

      transaction(fn ->
        write([id], [:foo, :bar, :foobar], [:bar], :foobar)
        write([id2], [:foo, :bar], [:bar], :foobar)
      end)

      assert transaction(fn -> 
        has_any([id], [:bar])
      end) == [{id, true}]

      assert transaction(fn -> 
        has_any([id], [:bar, :baz])
      end) == [{id, true}]

      assert transaction(fn -> 
        has_any([id], [:baz])
      end) == [{id, false}]

      assert transaction(fn -> 
        has_any([id, id2], [:bar, :baz])
      end) == [{id, true}, {id2, true}]

      assert transaction(fn -> 
        has_any([id, id2], [:foobar])
      end) == [{id, true}, {id2, false}]

      assert transaction(fn -> 
        has_any([id, id2], [:foobar], [:bar])
      end) == [{id, true}, {id2, false}]

      assert transaction(fn -> 
        has_any([id, id2],
                [:foobar],
                [:bar],
                [&(&1 === :foobar), fn(_) -> true end])
      end) == [{id, true}, {id2, false}]
    end

    test "has_which", %{id: id} = _context do
      id2 = new_entity()

      transaction(fn ->
        write([id], [:foo, :bar, :foobar], [:bar], :foobar)
        write([id2], [:foo, :bar], [:bar], :foobar)
      end)

      assert transaction(fn -> 
        has_which([id], [:bar])
      end) == [{id, %{bar: true}}]

      assert transaction(fn -> 
        has_which([id], [:oof])
      end) == [{id, %{oof: false}}]

      assert transaction(fn -> 
        has_which([id], [:bar, :oof])
      end) == [{id, %{oof: false, bar: true}}]

      assert transaction(fn -> 
        has_which([id, id2], [:bar, :oof])
      end) == [{id, %{oof: false, bar: true}}, {id2, %{oof: false, bar: true}}]

      assert transaction(fn -> 
        has_which([id, id2], [:bar, :oof], [:bar, :foo])
      end) == [
        {id,
          %{bar: %{bar: true, foo: false},
            oof: %{bar: false, foo: false}}},
        {id2, 
          %{bar: %{bar: true, foo: false},
            oof: %{bar: false, foo: false}}}
      ]

      assert transaction(fn -> 
        has_which([id, id2],
                  [:foo, :bar],
                  [:bar, :foo],
                  [&(&1 === :foobar), fn(_) -> true end])
      end) == [
        {id,
          %{bar: %{bar: true, foo: false},
            foo: %{bar: true, foo: false}}},
        {id2, 
          %{bar: %{bar: true, foo: false},
            foo: %{bar: true, foo: false}}}
      ]
    end
  end

  describe "list tests:" do
    setup [:setup_context]

    test "list", %{id: id} = _context do
      id2 = new_entity()
      
      transaction(fn ->
        write([id, id2], [:foo, :bar], [:bar, :foo], :foobar)
      end)
      
      assert transaction(fn ->
        list([id, id2])
      end) == [{id, [:bar, :foo]}, {id2, [:bar, :foo]}]
      
      assert transaction(fn ->
        list([id, id2], [:foo, :bar])
      end) == [
        {id,
          %{bar: [:bar, :foo],
            foo: [:bar, :foo]}},
        {id2,
          %{bar: [:bar, :foo],
            foo: [:bar, :foo]}}
      ]
    end
  end

  describe "find* tests:" do
    setup [:setup_context]

    test "find_with_all", %{id: id} = _context do
      id2 = new_entity()
      
      transaction(fn ->
        write([id, id2], [:oof, :rab], [:oof, :rab], :raboof)
      end)
      
      assert transaction(fn ->
        find_with_all([:oof, :rab])
      end) == [id, id2]
      
      assert transaction(fn ->
        find_with_all([:oof, :rabbar])
      end) == []
      
      assert transaction(fn ->
        find_with_all([:oof, :rab], [:oof, :rab])
      end) == [id, id2]
      
      assert transaction(fn ->
        find_with_all([:oof, :rab], [:oof, :rabbar])
      end) == []
      
      assert transaction(fn ->
        find_with_all([:oof, :rab],
                      [:oof, :rab],
                      [&(&1 === :raboof), fn(_) -> true end])
      end) == [id, id2]
      
      assert transaction(fn ->
        find_with_all([:oof, :rab],
                      [:oof, :rab],
                      [&(&1 === :foobar), fn(_) -> true end])
      end) == []
    end

    test "find_with_any", %{id: id} = _context do
      id2 = new_entity()
      
      transaction(fn ->
        write([id, id2], [:blarg, :blarb], [:blarg, :blarb], :meepmeep)
      end)
      
      assert transaction(fn ->
        find_with_any([:blarg, :glarb])
      end) == [id, id2]
      
      assert transaction(fn ->
        find_with_any([:glarb])
      end) == []
      
      assert transaction(fn ->
        find_with_any([:blarg, :glarb], [:blarg, :glarb])
      end) == [id, id2]
      
      assert transaction(fn ->
        find_with_any([:blarg, :glarb],
                      [:blarg, :glarb],
                      [&(&1 === :raboof), fn(_) -> true end])
      end) == [id, id2]
      
      assert transaction(fn ->
        find_with_any([:blarg, :glarb],
                      [:blarg, :glarb],
                      [&(&1 === :foobar)])
      end) == []
    end
  end

  describe "read tests:" do
    setup [:setup_context]

    test "read", %{id: id} = _context do
      id2 = new_entity()

      assert transaction(fn ->
        write([id, id2], [:foo, :bar], [:foo, :bar], :foobar)
      end) == :ok
      
      assert transaction(fn ->
        read([id, id2])
      end) == [
        {id, 
          %{foo: %{bar: :foobar, foo: :foobar},
            bar: %{bar: :foobar, foo: :foobar}}},
        {id2, 
          %{foo: %{bar: :foobar, foo: :foobar},
            bar: %{bar: :foobar, foo: :foobar}}}
      ]

      assert transaction(fn ->
        read([id, id2], [:foo, :bar])
      end) == [
        {id, 
          %{foo: %{bar: :foobar, foo: :foobar},
            bar: %{bar: :foobar, foo: :foobar}}},
        {id2, 
          %{foo: %{bar: :foobar, foo: :foobar},
            bar: %{bar: :foobar, foo: :foobar}}}
      ]

      assert transaction(fn ->
        read([id, id2], [:foo, :bar], [:foo, :bar])
      end) == [
        {id, 
          %{foo: %{bar: :foobar, foo: :foobar},
            bar: %{bar: :foobar, foo: :foobar}}},
        {id2, 
          %{foo: %{bar: :foobar, foo: :foobar},
            bar: %{bar: :foobar, foo: :foobar}}}
      ]

      assert transaction(fn ->
        read([id, id2], [:foo, :bar], [:foo])
      end) == [
        {id, 
          %{foo: %{foo: :foobar},
            bar: %{foo: :foobar}}},
        {id2, 
          %{foo: %{foo: :foobar},
            bar: %{foo: :foobar}}}
      ]

      assert transaction(fn ->
        read([id, id2], [:foo], [:foo, :bar])
      end) == [
        {id, 
          %{foo: %{bar: :foobar, foo: :foobar}}},
        {id2, 
          %{foo: %{bar: :foobar, foo: :foobar}}}
      ]
    end
  end

  describe "write tests:" do
    setup [:setup_context]

    test "write", %{id: id} = _context do
      id2 = new_entity()

      assert transaction(fn ->
        write([id], [:foo], [:bar], :foobar)
      end) == :ok
      
      assert transaction(fn ->
        write([id, id2], [:foo], [:bar], :foobar)
      end) == :ok
      
      assert transaction(fn ->
        write([id, id2], [:foo, :bar], [:bar, :foo], :foobar)
      end) == :ok
      
      assert transaction(fn ->
        read([id, id2])
      end) == [
        {id, 
          %{foo: %{bar: :foobar, foo: :foobar},
            bar: %{bar: :foobar, foo: :foobar}}},
        {id2, 
          %{foo: %{bar: :foobar, foo: :foobar},
            bar: %{bar: :foobar, foo: :foobar}}}
      ]
    end
  end

  defp setup_context(_context) do
    %{id: new_entity()}
  end

  defp setup_mnesia(_context) do
    Mnesia.initialize()
  end

  defp new_entity do
    Mnesia.create()
  end
end
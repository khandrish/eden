defmodule Eden.EntityTest do
  use Eden.ModelCase

  alias Eden.Entity

  @valid_attrs %{component: "some content", entity: "7488a646-e31f-11e4-aace-600308960662", key: "some content", value: "some content"}
  @invalid_attrs %{}

  test "insert and delete entity" do
    components = %{"foo": %{"foo": "bar"}}
    entity = %Entity{components: :erlang.term_to_binary(components)}
    |> Repo.insert!
    Repo.delete! entity
  end
end

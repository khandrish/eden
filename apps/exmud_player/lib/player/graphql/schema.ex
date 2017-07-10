defmodule Exmud.Player.Graphql.Schema do
  alias Exmud.Player.Graphql.Resolver.ObjectResolver
  alias Exmud.Player
  alias Exmud.Player.Repo
  import Ecto.Query
  use Absinthe.Schema
  use Absinthe.Schema.Notation
  import_types Exmud.Player.Graphql.Types

  def middleware(middleware, _field, %{identifier: :mutation}) do
    middleware ++ [Exmud.Engine.Graphql.Middleware.ChangesetErrorFormatter]
  end

  def middleware(middleware, _, _) do
    middleware
  end

  query do
    @desc "Get an object by ID."
    field :object, type: :object do

      @desc "The ID of the object"
      arg :id, :id

      resolve &ObjectResolver.one/2
    end

    @desc "Get all objects with a particular key."
    field :objects, type: list_of(:object) do

      @desc "The key of the object"
      arg :key, :string

      resolve &ObjectResolver.many/2
    end

    @desc "Get a component connected to an object."
    field :component, type: :component do

      arg :component, :string
      arg :object_id, :id

      resolve &ComponentResolver.many/2
    end

    @desc "Get all components by connected to an object."
    field :components, type: :component do

      arg :object_id, :id

      resolve &ComponentResolver.many/2
    end

    @desc "Get all components connected to an object."
    field :component, type: :component do

      arg :object_id, :id
      arg :component, :string

      resolve &ComponentResolver.many/2
    end
  end
end

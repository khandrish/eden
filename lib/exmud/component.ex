defmodule Exmud.Component do
  alias Exmud.Db

  @doc false
  defmacro __using__(_) do
    quote location: :keep do
      @behaviour Exmud.Component
      alias Exmud.Db

      @doc false
      def init(entity, args) do
        Db.transaction(fn ->
          Db.write(entity, __MODULE__, __MODULE__, true)
        end)
      end

      defoverridable [init: 2]
    end
  end

  def add(entity, component, args \\ %{}) do
    component.init(entity, args)
    entity
  end

  def remove(entity, component) do
    Db.transaction(fn ->
      Db.delete(entity, component)
    end)
  end
end

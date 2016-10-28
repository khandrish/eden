defmodule Eden.ComponentBase do
  defmacro __using__(_opts) do
    quote do
      def before_create(component), do: component
      def after_create(id, _component), do: id

      def init(id, _component), do: id

      def before_add_key(id, _component, _key, _value), do: id
      def after_add_key(id, _component, _key, _value), do: id

      def before_remove_key(id, _component, _key), do: id
      def after_remove_key(id, _component, _key), do: id

      def before_update_key(id, _component, _key), do: id
      def after_update_key(id, _component, _key), do: id

      def before_delete(id), do: id
      def after_delete(id), do: id

      defoverridable [before_create: 1,
      				        after_create: 2,
                      init: 2,
                      before_add_key: 4,
                      after_add_key: 4,
                      before_remove_key: 3,
                      after_remove_key: 3,
                      before_update_key: 3, 
                      after_update_key: 3,
                      before_delete: 1,
                      after_delete: 1]
    end
  end
end
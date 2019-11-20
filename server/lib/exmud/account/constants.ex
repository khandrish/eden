defmodule Exmud.Account.Constants do
  defmodule PlayerStatus do
    @spec created :: atom
    def created, do: :created
    @spec invited :: atom
    def invited, do: :invited
    @spec pending :: atom
    def pending, do: :pending
  end
end

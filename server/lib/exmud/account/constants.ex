defmodule Exmud.Account.Constants do
  defmodule PlayerStatus do
    @spec created :: String.t()
    def created, do: "created"
    @spec invited :: String.t()
    def invited, do: "invited"
    @spec pending :: String.t()
    def pending, do: "pending"
  end
end

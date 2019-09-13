defmodule Exmud.Account.Constants do
  defmodule PlayerStatus do
    @spec invited :: <<_::56>>
    def invited, do: "invited"
    @spec registered :: <<_::80>>
    def registered, do: "registered"
  end
end

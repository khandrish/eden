defmodule Eden.Plug.ScrubExistingParams do
  @moduledoc """
    Authenticated plug can be used ensure an action can only be triggered by
    players that are authenticated.
  """
  import Plug.Conn

  def init(scrubbable_params) do
    scrubbable_params
  end

  def call(%Plug.Conn{params: params} = conn, scrubbable_params) do
    params = Enum.reduce(params, %{}, fn({key, value}, scrubbed_params) ->
      if key in scrubbable_params do
        value = scrub_param(value)
      end

      Map.put(scrubbed_params, key, value)
    end)

    %{conn | params: params}
  end

  defp scrub_param(%{__struct__: mod} = struct) when is_atom(mod) do
    struct
  end
  
  defp scrub_param(%{} = param) do
    Enum.reduce(param, %{}, fn({k, v}, acc) ->
      Map.put(acc, k, scrub_param(v))
    end)
  end
  
  defp scrub_param(param) when is_list(param) do
    Enum.map(param, &scrub_param/1)
  end
  
  defp scrub_param(param) do
    if scrub?(param), do: nil, else: param
  end

  defp scrub?(" " <> rest), do: scrub?(rest)
  defp scrub?(""), do: true
  defp scrub?(_), do: false
end

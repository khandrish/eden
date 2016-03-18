defmodule Eden.Api.Player do
  @moduledoc """
  This layer bridges the channels and the system logic.
  """

  alias Eden.Player
  import Eden.Api.Context
  use Eden.Web, :channel

  def handle_in("player:create", params, context) do
    case Player.create(params) do
      {:ok, player} ->
        context
        |> set_result_code(:ok)
        |> set_result_data(player)
      _ ->
        context
        |> set_result_code(:error)
        |> set_result_data("Unable to create player")
    end
  end

  def handle_in("player:delete", %{"id" => id} = params, context) do
    case Player.delete(id) do
      {:ok, _player} ->
        context
        |> set_result_code(:ok)
        |> set_result_data("Player successfully deleted")
      _ ->
        context
        |> set_result_code(:error)
        |> set_result_data("Unable to delete player")
    end
  end

  def handle_in("player:read", %{"id" => id} = params, context) do
    case Player.read(id) do
      {:ok, player} ->
        context
        |> set_result_code(:ok)
        |> set_result_data(player)
      _ ->
        context
        |> set_result_code(:error)
        |> set_result_data("Unable to delete player")
    end
  end
end


defmodule Eden.PlayerToken do
  @moduledoc """
  
  Provides the interface for working with PlayerTokens. When working with
  PlayerToken objects they should be considered opaque and manipulation
  should be handled by this module.
  
  """

  alias Eden.Repo
  alias Eden.Schema.PlayerToken, as: PlayerTokenSchema
  import Ecto
  import Ecto.Changeset
  import Ecto.Query, only: [from: 2]
  require Logger
  use Pipe

  #
  # API
  #

  def create(player, params) do
    {status, player_token} = result =
      Repo.insert build_assoc(player, :player_tokens, params)

    if status == :ok do
      Logger.info "PlayerToken #{player_token.id} of type #{player_token.type} created on player #{player.id}"
    else
      Logger.warn "Unable to save player token when creating"
    end

    result
  end

  def delete(token) when is_binary(token) do
    delete(Repo.get_by(PlayerTokenSchema, token: token))
  end

  def delete(nil) do
    {:error, :invalid_token}
  end

  def delete(token) do
    {status, _} = result = Repo.delete token

    if status == :error, do: Logger.warn "Unable to delete player token #{token.id}"

    result
  end

  def delete_all(player) do
    query = from pt in PlayerTokenSchema,
              where: pt.player_id == ^player.id
              
    Repo.delete_all query
  end

  def delete_all(player, type) do
    query = from pt in PlayerTokenSchema,
              where: pt.player_id == ^player.id,
              where: pt.type == ^type

    Repo.delete_all query
  end

  def is_active?(token) do
    is_active?(token, Calendar.DateTime.now_utc)
  end


  #
  # Private Functions
  #

  defp is_active?(token, now) do
    if Calendar.DateTime.after?(token.expiry, now) do
      true
    else
      false
    end
  end
end
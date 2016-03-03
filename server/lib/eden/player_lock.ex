defmodule Eden.PlayerLock do
  @moduledoc """
  
  Provides the interface for working with PlayerLocks. When working with
  PlayerLock objects they should be considered opaque and manipulation
  should be handled by this module.
  
  """

  alias Eden.Repo
  alias Eden.Schema.PlayerLock, as: PlayerLockSchema
  alias Eden.Time, as: ET
  import Ecto
  import Ecto.Changeset
  import Ecto.Query, only: [from: 2]
  require Logger
  use Pipe

  #
  # API
  #

  def any_active_locks?(locks) do
    any_active_locks?(:any, locks)
  end

  def any_active_locks?(type, locks) do
    any_active_locks?(type, locks, ET.now_utc)
  end

  def create(player, params) do
    {status, player_lock} = result =
      Eden.Repo.insert build_assoc(player, :player_locks, params)

    if status == :ok do
      Logger.info "PlayerLock `#{player_lock.id}` of type `#{player_lock.type}` created on player `#{player.id}`"
    else
      Logger.warn "Unable to save player lock when creating"
    end

    result
  end

  def is_active?(lock) do
    is_active?(lock, ET.now_utc)
  end


  #
  # Private Functions
  #

  defp any_active_locks?(_, [], _) do
    false
  end

  defp any_active_locks?(:any, [lock|locks], now) do
    if is_active?(lock, now) do
      true
    else
      any_active_locks?(:any, locks, now)
    end
  end

  defp any_active_locks?(type, [lock|locks], now) do
    if lock.type == type and is_active?(lock, now) do
      true
    else
      any_active_locks?(type, locks, now)
    end
  end

  defp is_active?(lock, now) do
    if Calendar.DateTime.after?(lock.expiry, now) do
      true
    else
      false
    end
  end
end
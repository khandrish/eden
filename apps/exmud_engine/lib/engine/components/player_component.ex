defmodule Exmud.Engine.Component.PlayerComponent do
  @moduledoc """
  A Player is the in-engine representation of an Account.

  A Player component has the following required fields:
    - account_id
  """
  use Exmud.Engine.Component
  alias Exmud.Engine.Attribute

  @spec populate( integer, Map.t() ) :: :ok | :error
  def populate( object_id, config ) do
    Attribute.put( object_id, __MODULE__, account_id(), Map.get( config, account_id() ) )
  end

  #
  # Attributes
  #

  @doc """
  A Player belongs to a single account
  """
  def account_id, do: "account_id"
end

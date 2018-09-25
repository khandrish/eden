defmodule Exmud.Engine.Schema.System do
  use Exmud.Common.Schema

  schema "system" do
    field( :callback_module, :binary )
    field( :state, :binary )
  end

  def new( params ) do
    %Exmud.Engine.Schema.System{}
    |> cast(params, [ :callback_module, :state ] )
    |> validate_required( [ :callback_module, :state ] )
  end
end

defmodule Exmud.Engine.Schema.Engine do
  use Exmud.Common.Schema

  schema "engine" do
    field( :initialized, :boolean, default: false )
  end

  def new( params ) do
    %Exmud.Engine.Schema.Attribute{}
    |> cast(params, [ :initialized ] )
  end
end

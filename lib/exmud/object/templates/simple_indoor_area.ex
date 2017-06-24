defmodule Exmud.Object.Template.SimpleIndoorArea do
  @moduledoc """
  A simple area with a static description and no special interactivity.
  """
  alias Ecto.Multi
  alias Exmud.Object.Component.Region
  import Exmud.Object

  @default_description "It's a place. It's nifty."

  def define(oid, args) do
    # define components, this is your data
    {:ok, _} = add_component(oid, Area)
    {:ok, _} = add_attribute(oid, Area, "description", Map.get(args, "description", @default_description))

    case Map.get(args, "region") do
      nil ->
        # get base region
        region =
          Multi.new()
          |>  list("list objects", components: Region)

        {:ok, _} = add_attribute(oid, Area, "region", region)
      region ->
        {:ok, _} = add_attribute(oid, Area, "region", region)
    end
    # define command sets, this is your logic
    # define locks, this is your permissions
    # define scripts, this is your logic
    # define callbacks, this is your logic
  end
end
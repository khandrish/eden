defmodule Exmud.Object.Factory do
  @moduledoc """
  Every object that is created is generated via this module.

  The factory takes a template an an optional args argument, and triggers the `define/1` function on the template. This
  is done in the context of a transaction so that all database modifications are made in a single atomic action.
  """
  alias Exmud.Object

  @doc """
  Define the component.

  Given the object on which a component is being added and a set of optional arguments, populate the component with the
  expected set of attributes.
  """
  def generate(object_template, args \\ nil) do
    generate_function =
      fn() ->
        {:ok, oid} = Object.new()
        object_template.define(oid, args)
      end

    case Ecto.Repo.transaction(generate_function) do
      :ok ->  :ok
      {:error, _error_message} = error -> error
    end
  end
end
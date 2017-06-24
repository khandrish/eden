defmodule Exmud.Component do
  @moduledoc """
  A component acts as both a flag and a namespace for attributes on an object.

  For example, a container component might be expected to have attributes for the weight/size limit of items placed in
  it, while a weapon might have the type and amount of damage caused.
  """

  @doc """
  Define the component.

  Given the object on which a component is being added and a set of optional arguments, populate the component with the
  expected set of attributes.
  """
  @callback define(term, term) :: term
end
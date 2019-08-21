defmodule ExmudWeb.DatatableLiveProvider do
  @moduledoc """
  A provider performs the actual manipulation of the data and used as a callback module by a DatatableLive controller.

  The controller abstracts away as many implementation details as possible while simultaneously providing as many hooks
  as possible to customize datatable behaviour. By including 'use ExmudWeb.DatatableLiveProvider' in a module a set of
  default, overridable, callbacks will be defined. In addition the statement '@behaviour ExmudWeb.DatatableLiveProvider'
  will be injected as well to ensure the required callbacks are implemented.

  The documentation below is explicit about which callbacks are required and which have provided defaults.
  """

  @doc """
  Whether it is the first time loading data for a datatable or the millionth, this is the function called.

  The args passed into the DatatableLive controller when rendering are preserved and passed into this callback function
  on every request. This is useful for things like being able to list all templates associated with a simulation, for
  example, by passing in '%{simulation: 42}'.

  The implementation of this callback must take into account pagination. See 'ExmudWeb.DatatableLive.State' for the full
  documentation on what data is available for customizing queries.
  """
  @callback load(ExmudWeb.DatatableLive.State.t()) ::
              {:ok, ExmudWeb.DatatableLive.State.t()} | {:error, error :: term}
end

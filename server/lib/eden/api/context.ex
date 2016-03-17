defmodule Eden.Api.Context do
  @moduledoc """
  The `opaque` data structure and associated logic that make up API contexts.

  This context is passed through a series of handlers and includes all data
  pertaining to the api operation. At the end of the chain it's expected that
  the context object will be populated with a result code, with a message
  being optional.

  A context object only lasts for a single operation, and is the common thread
  that allows the tracing of operations through log output when working with
  several independent systems. For example a handler chain might include a
  throttling check, and a permissions check before executing the code that
  actually makes up the operation.
  """

  defstruct result_message: nil, request_id: nil, result_code: nil, socket: nil

  def new, do: %Eden.Api.Context{request_id: Ecto.UUID.generate}

  def new(socket), do: %Eden.Api.Context{request_id: Ecto.UUID.generate, socket: socket}

  # Reply Message functions

  def get_result_message(context), do: context.result_message

  def set_result_message(context, result_message), do: %{context | result_message: result_message}

  # Request Id functions

  def get_request_id(context), do: context.request_id

  # Result Code functions

  def get_result_code(context), do: context.result_code

  def set_result_code(context, result_code), do: %{context | result_code: result_code}

  # Socket functions

  def get_socket(context), do: context.socket

  def set_socket(context, socket), do: %{context | socket: socket}

end
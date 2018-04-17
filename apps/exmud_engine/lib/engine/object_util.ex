defmodule Exmud.Engine.ObjectUtil do
  @moduledoc """
  This module is primarily for the internal use of the Engine, but is documented for completeness. If you are doing
  basic game development, you may discontinue reading.
  """

  alias Exmud.Engine.Cache
  alias Exmud.Engine.Repo
  import Ecto.Query
  import Exmud.Common.Utils
  import Exmud.Engine.Utils
  require Logger

  @doc """
  The unique name of the Component.

  This unique string is used for registration in the Engine, and can be used to attach/detach Components.
  """
  @callback name :: String.t

  @typedoc "The Object being populated with the Component and its data."
  @type object_id :: integer

  @typedoc "Configuration passed through to a callback module."
  @type config :: term

  @typedoc "The name of an Attribute belonging to a Component."
  @type attribute :: String.t()

  @typedoc "An error returned when something has gone wrong."
  @type error :: atom

  @typedoc "The callback_module that is the implementation of the Component logic."
  @type callback_module :: atom

  @typedoc "A function passed in to be executed upon some criteria being met."
  @type callback_function :: atom

  @typedoc "An Ecto struct."
  @type record :: struct()

  @doc """
  Atomically attach a record to an Object and optionally call a callback function on success.

  Callback function must return `:ok` or `{:error, error}` where error is an atom to be used for pattern matching.

  A transaction wraps both the record insert and the callback function. Should an exception be raused during the
  callback, the transaction will rollback and the response `{:error, :callback_failed}` will be returned.
  """
  @spec attach(record, callback_function) :: :ok | {:error, :no_such_object} | {:error, :already_attached} | {:error, :callback_failed} | {:error, error}
  def attach(record, callback_function \\ nil) do
    Repo.transaction(fn ->
      record
      |> Repo.insert()
      |> normalize_repo_result()
      |> case do
        :ok ->
          if is_function(callback_function) do
            try do
              case callback_function.() do
                :ok -> :ok
                {:error, error} -> Repo.rollback(error)
              end
            rescue
              _ -> Repo.rollback(:callback_failed)
            end
          else
            :ok
          end
        {:error, [object_id: _error]} ->
          Repo.rollback(:no_such_object)
        {:error, [{_, "has already been taken"}]} = _ ->
          Repo.rollback(:already_attached)
      end
    end)
    |> normalize_repo_result()
  end
end
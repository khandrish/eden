defmodule Db do
  @moduledoc """
  Wrapper around database interactions.
  """
  import Ecto.Query

  def count(query, repo, prefix) when is_atom(repo) and is_binary(prefix) do
    query
    |> select([m], count(m.id))
    |> repo.one!(prefix: prefix)
  end

  def delete(model, repo, prefix) when is_atom(repo) and is_map(model) and is_binary(prefix) do
    repo.delete!(model, prefix: prefix)
  end

  def delete(query, repo, prefix) when is_atom(repo) and is_binary(prefix) do
    repo.delete_all!(query, prefix: prefix)
  end

  def get(query, repo, prefix) when is_atom(repo) and is_binary(prefix) do
    repo.one!(query, prefix: prefix)
  end

  def get(repo, model, model_id, prefix)
      when is_map(model) and is_atom(repo) and is_integer(model_id) and is_binary(prefix) do
    repo.get!(model, model_id, prefix: prefix)
  end

  def insert(model, repo, prefix) when is_map(model) and is_binary(prefix) do
    repo.insert!(model, prefix: prefix)
  end

  def list(query, repo, prefix) when is_binary(prefix) do
    repo.all!(query, prefix: prefix)
  end

  @doc """
  Execute a function as part of a transaction that can be retried.

  Retries are performed with an exponential backoff and jitter to reduce congestion with the DB while performing work
  as quickly as possible.

  NOTE: Nested transactions are not a thing. This should only be used at the outermost layer of logic otherwise the
  behaviour is undefined and will likely cause problems as an explicit Rollback is performed and only the submitted
  function will be run again. Data will be lost.

  Has the following options:
    max_retries: integer() | :unlimited (default)
    max_backoff: integer() (default: 100)
    min_backoff: integer() (default: 2)
  """
  @default_option_values [
    max_retries: :unlimited,
    # milliseconds,
    max_backoff: 100,
    # milliseconds
    min_backoff: 2
  ]
  def retryable_transaction(callback, repo, prefix, options \\ [])
      when is_function(callback) and is_atom(repo) and is_binary(prefix) do
    options = Map.new(Keyword.merge(@default_option_values, options))

    execute_callback(callback, options, repo, prefix, 0)
  end

  def update(model, repo, prefix) when is_map(model) and is_atom(repo) and is_binary(prefix) do
    repo.update(model, prefix: prefix)
  end

  #
  # Private functions
  #

  defp execute_callback(callback, %{max_retries: max_retries} = options, repo, prefix, retries)
       when max_retries == :unlimited or
              max_retries >= retries do
    # If retries is > 0 this is not the first attempt to run this callback due to a serialization error, backoff
    if retries > 0 do
      # See: https://aws.amazon.com/blogs/architecture/exponential-backoff-and-jitter/
      backoff = Enum.random(0..min(options.max_backoff, 2 * trunc(:math.pow(2, retries))))

      # This process should be blocked during the backoff period as this should be synchronous from outside
      Process.sleep(backoff)
    end

    repo.transaction(fn ->
      # Every transaction should have an isolated view of the data
      repo.query("set transaction isolation level serializable;")

      try do
        callback.()
      rescue
        error in Postgrex.Error ->
          if error.postgres.code == :serialization_failure do
            repo.rollback(:serialization_failure)
          else
            reraise(error, __STACKTRACE__)
          end
      end
    end)
    |> case do
      {:error, :serialization_failure} ->
        execute_callback(callback, options, repo, prefix, retries + 1)

      {_, result} ->
        result
    end
  end

  defp execute_callback(_, _, _, _, _) do
    {:error, :retries_exceeded}
  end
end

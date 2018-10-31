defmodule Exmud.Common.Utils do
  @moduledoc false

  def cfg(first_key, second_key), do: Application.get_env(first_key, second_key)

  def normalize_ecto_errors(errors), do: Enum.map(errors, fn({key, {error, _}}) -> {key, error} end)

  def normalize_multi_result({:ok, _results}), do: :ok
  def normalize_multi_result({:ok, results}, desired_result), do: {:ok, results[desired_result] || desired_result}

  def normalize_multi_result({:error, _, %Ecto.Changeset{} = changeset, _}, _) do
    {:error, normalize_ecto_errors(changeset.errors)}
  end

  def normalize_multi_result({:error, _, error, _}, _), do: {:error, error}

  def normalize_repo_result({:ok, _}), do: :ok
  def normalize_repo_result({:error, changeset}) when is_map(changeset) do
    {:error, normalize_ecto_errors(changeset.errors)}
  end
  def normalize_repo_result(error), do: error

  def normalize_repo_result({:ok, _}, desired_result), do: {:ok, desired_result}
  def normalize_repo_result({:error, changeset}, _), do: {:error, normalize_ecto_errors(changeset.errors)}

  def normalize_insert_result({:ok, record}), do: {:ok, record.id}
  def normalize_insert_result({:error, changeset}), do: {:error, normalize_ecto_errors(changeset.errors)}

  def via(registry, key), do: {:via, Registry, {registry, key}}

  def get_moduledoc( module, language \\ "en" ) do
    docs = Code.fetch_docs( module )
    case elem(docs, 4) do
      :none ->
        :none
      doc_languages ->
        String.trim( Map.get(doc_languages, language) )
    end
  end

  # Check to see if the gzip header is present, and if it is gunzip first.
  def unpack_term( << 31::size( 8 ), 139::size( 8 ), 8::size( 8 ), _rest::binary >> = bin ) do
    try do
      bin
      |> :zlib.gunzip()
      |> :erlang.binary_to_term()
    rescue
      :data_error ->
        :erlang.binary_to_term( bin )
    end
  end

  def unpack_term( bin ), do: :erlang.binary_to_term( bin )

  @compression_threshold_bytes Application.get_env( :exmud_common, :byte_size_to_compress )
  def pack_term( term ) do
    bin = :erlang.term_to_binary( term )

    if byte_size( bin ) >= @compression_threshold_bytes do
      :zlib.gzip( bin )
    else
      bin
    end
  end
end

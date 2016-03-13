defmodule Eden.Session do
  alias Eden.Player
  alias Eden.Repo
  alias Eden.Schema.Session, as: SessionSchema
  alias Eden.Time, as: ET
  import Ecto.Changeset
  import Ecto.Query, only: [from: 2]
  require Logger

  #
  # API
  #

  def authenticate(session, login, password) do
    case Player.authenticate(login, password) do
      {:ok, player} ->
        {status, _} = result =
          session
          |> change(%{:data => Map.put(session.data, "player", player)})
          |> serialize
          |> Repo.update

        if status == :error do
          Logger.warn "Unable to save session when authenticating"
        end

        result
      _ ->
        Logger.warn "ERROR WHEN AUTHENTICATING"
        {:error, session}
    end
  end

  def initialize(token) do
    Logger.debug "INITIALIZING TOKEN: #{token}"
    query = from s in SessionSchema,
              where: s.token == ^token,
              select: s

    case Repo.one(query) do
      nil ->
        Logger.debug "NO SESSION FOUND"
        {status, _} = result =
          %Eden.Schema.Session{token: token, expiry: session_expiry, data: %{}}
          |> serialize
          |> Repo.insert

        if status == :error do
          Logger.warn "Unable to save session when initializing"
        end

        result
      session ->
        Logger.debug "SESSION FOUND"
        {:ok, session}
    end
  end

  def is_authenticated?(session) do
    data =
      session
      |> change
      |> deserialize
      |> get_field(:data)

    Map.has_key?(data, "player")
  end

  def repudiate(session) do
    {status, _} = result = 
      session
      |> change(%{:data => Map.delete(get_field(change(session), :data), "player")})
      |> serialize
      |> Repo.update

    if status == :error do
      Logger.warn "Unable to save session when repudiating"
    end

    result
  end

  def update(session) do
    result =
      session
      |> change
      |> serialize
      |> Repo.update

    case result do
      {:ok, _} ->
        result
      {:error, _} ->
        Logger.warn "Unable to save session #{session.id} when updating"
        result
    end
  end


  #
  # General use private functions
  #

  defp deserialize(session) do
    session = change(session)
    put_change(session, :data, :erlang.binary_to_term(get_field(session, :db_data)))
  end

  defp serialize(session) do
    session = change(session)
    put_change(session, :db_data, :erlang.term_to_binary(get_field(session, :data)))
  end

  defp session_expiry do
    session_ttl = Application.get_env(:eden, :session_ttl)
    ET.timestamp_after_utc(session_ttl)
  end

end

defmodule Eden.Player do
  use Eden.Web, :changeset
  alias Eden.Repo
  import Comeonin.Bcrypt, only: [hashpwsalt: 1]

  schema "players" do
    field :login, :string
    field :last_login, Calecto.DateTimeUTC
    field :failed_login_attempts, :integer, default: 0
    has_many :player_locks, Eden.PlayerLock
    has_many :player_tokens, Eden.PlayerToken

    field :email, :string
    field :email_verified, :boolean, default: false
    
    field :hash, :string

    field :name, :string
    field :last_name_change, Calecto.DateTimeUTC

    field :password, :string, virtual: true

    timestamps
  end

  #
  # API
  #

  def insert(player) do
    player
    |> Repo.insert!
  end

  def new(params) do
    cs = %Eden.Player{}
    |> cast(params, ~w(login name email password))
    |> validate_params

    if cs.valid? do
      cs
      |> handle_password_update
    else
      cs
    end
  end

  def save(player) do
    Repo.update! player
  end

  def update(player, key, value) do
    update(player, %{key: value})
  end

  def update(player, params) do
    cs = cast(player, params, [], ~w(email email_verified failed_login_attempts last_login last_name_change login name password))
    |> validate_params

    if cs.valid? do
      cs
      |> handle_password_update
      |> handle_email_update
      |> handle_name_update
    else
      cs
    end

  end

  #
  # Private Functions
  #

  defp handle_password_update(changeset) do
    case fetch_change(changeset, :password) do
      {:ok, password} -> put_change(changeset, :hash, hashpwsalt(password))
      :error -> changeset
    end
  end

  defp handle_email_update(changeset) do
    if fetch_change(changeset, :email) != :error do
      put_change(changeset, :email_verified, false)
    else
      changeset
    end
  end

  defp handle_name_update(changeset) do
    if fetch_change(changeset, :name) != :error do
      put_change(changeset, :last_name_change, Calendar.DateTime.now_utc)
    else
      changeset
    end
  end

  defp validate_params(changeset) do
    changeset
    |> validate_length(:login, min: 12, max: 255)
    |> unique_constraint(:login)
    |> validate_length(:password, min: 12, max: 50)
    |> validate_format(:email, ~r/@/)
    |> validate_length(:name, min: 2, max: 50)
    |> unique_constraint(:name)
    |> unique_constraint(:id)
  end
end

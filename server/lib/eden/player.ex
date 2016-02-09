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
    cs = cast(player, params, [])
    |> validate_params

    if cs.valid? do
      cs
      |> handle_password_update
      |> handle_email_update
      |> handle_name_update
    end
  end

  #
  # Private Functions
  #

  defp handle_password_update(changeset) do
    password = fetch_change(changeset, :password)
    if password != :error do
      put_change(changeset, :hash, hashpwsalt(password))
    else
      changeset
    end
  end

  defp handle_email_update(changeset) do
    email = fetch_change(changeset, :email)
    if email != :error do
      put_change(changeset, :email_verified, false)
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

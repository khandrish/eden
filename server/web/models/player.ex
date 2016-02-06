defmodule Eden.Player do
  use Eden.Web, :model
  alias Eden.Repo

  schema "players" do
    field :login, :string
    field :last_login, Ecto.DateTime
    field :failed_login_attempts, :integer, default: 0
    has_many :player_locks, Eden.PlayerLock
    has_many :player_tokens, Eden.PlayerToken

    field :email, :string
    field :email_verified, :boolean, default: false
    
    field :hash, :string

    field :name, :string
    field :last_name_change, Ecto.DateTime

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
    result = %Eden.Player{}
    |> cast(params, ~w(login name email password), [])
    |> validate_params
  end

  def save(player) do
    Repo.update! player
  end

  def update(player, key, value) do
    update(player, %{key: value})
  end

  def update(player, params) do
    p = ~w(email email_verified failed_login_attempts hash last_login last_name_change login name password)
    cast(player, params, [], p)
    |> validate_params
  end

  #
  # Private Functions
  #

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

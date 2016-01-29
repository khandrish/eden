defmodule Eden.Player do
  use Eden.Web, :model

  schema "players" do
    field :login, :string
    field :last_login, Ecto.DateTime
    field :failed_login_attempts, :integer, default: 0
    embeds_one :login_lock, Eden.Player.Lock

    field :email, :string
    field :email_verified, :boolean, default: false
    field :email_verification_token, :string
    
    field :hash, :binary

    field :name, :string
    field :last_name_change, Ecto.DateTime

    field :password, :string, virtual: true
    field :password_reset_token, :string

    timestamps
  end

  @create_required_fields ~w(login name email password)
  def changeset(:create, model, params) do
    model
    |> cast(params, @create_required_fields)
    |> validate_params
  end

  @update_required_fields ~w()
  @update_optional_fields ~w(email name login password)
  def changeset(:update, model, params) do
    model
    |> cast(params, @update_required_fields, @update_optional_fields)
    |> validate_params
  end

  defp validate_params(changeset) do
    changeset
    |> validate_length(:login, min: 12, max: 255)
    |> unique_constraint(:login)
    |> validate_length(:password, min: 12, max: 50)
    |> validate_format(:email, ~r/@/)
    |> validate_length(:name, min: 2, max: 50)
    |> unique_constraint(:name)
  end
end

defmodule Eden.Player.Token do
  use Eden.Web, :model

  embedded_schema do
    field :token, :string
  end
end

defmodule Eden.Player.Lock do
  use Eden.Web, :model

  embedded_schema do
    field :reason, :string
    field :start, Ecto.DateTime
    field :end, Ecto.DateTime
  end
end

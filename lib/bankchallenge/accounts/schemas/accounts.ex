defmodule BankChallenge.Accounts.Schemas.Account do
  use Ecto.Schema
  import Ecto.Changeset
  alias BankChallenge.Accounts.Schemas, as: S

  @primary_key {:account_number, :binary_id, autogenerate: false}
  @derive {Phoenix.Param, key: :account_number}

  schema "accounts" do
    field :username, :string, unique: true
    field :email, :string
    field :password, :string, virtual: true
    field :hashed_password, :string
    field :balance, :integer
    has_many :account_number_transaction, S.Transaction, foreign_key: :account_number
    has_many :to_account_number_transaction, S.Transaction, foreign_key: :to_account_number

    timestamps()
  end

  @doc false
  def create_account_changeset(account, attrs) do
    account
    |> cast(attrs, [:username, :email, :password])
    |> validate_required([:username, :email, :password])
    |> put_change(:account_number, UUID.uuid4())
    |> put_change(:balance, 1000)
    |> validate_format(:email, ~r/@/)
    |> put_password_hash()
  end
  
  def insert_changeset(account, attrs) do
    account
    |> cast(attrs, [:account_number, :username, :email, :hashed_password, :balance])
    |> validate_required([:account_number, :username, :email, :hashed_password, :balance])
    |> validate_format(:email, ~r/@/)
    |> unique_constraint(:username)
  end

  defp put_password_hash(%Ecto.Changeset{valid?: true, changes: %{password: password}} = changeset) do
    change(changeset, hashed_password: Bcrypt.hash_pwd_salt(password))
  end

  defp put_password_hash(changeset), do: changeset
end

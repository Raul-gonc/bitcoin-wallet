defmodule Bitcoinwallet.Wallet.Transaction do
  @derive {Jason.Encoder, only: [:id, :symbol, :amount, :price, :date, :user_id, :inserted_at, :updated_at]}
  use Ecto.Schema
  import Ecto.Changeset

  # Transaction schema definition
  schema "transactions" do
    field :symbol, :string
    field :amount, :float
    field :price, :float
    field :date, :date
    belongs_to :user, Bitcoinwallet.Accounts.User

    timestamps()
  end

  # Changeset for transaction creation and validation
  def changeset(transaction, attrs) do
    transaction
    |> cast(attrs, [:symbol, :amount, :price, :date, :user_id])
    |> validate_required([:symbol, :amount, :price, :date, :user_id])
  end
end

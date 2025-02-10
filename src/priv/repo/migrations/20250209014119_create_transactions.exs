defmodule Bitcoinwallet.Repo.Migrations.CreateTransactions do
  use Ecto.Migration

  def change do
    create table(:transactions) do
      add :symbol, :string
      add :amount, :float
      add :price, :float
      add :date, :date
      add :user_id, references(:users, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:transactions, [:user_id])
  end
end

defmodule Bitcoinwallet.Repo.Migrations.AddIndexes do
  use Ecto.Migration

  def change do
    create_if_not_exists index(:transactions, [:symbol])

    create_if_not_exists index(:transactions, [:date])

    create_if_not_exists index(:transactions, [:user_id, :symbol])
  end
end

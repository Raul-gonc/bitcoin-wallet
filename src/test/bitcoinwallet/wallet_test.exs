defmodule Bitcoinwallet.WalletTest do
  use Bitcoinwallet.DataCase

  alias Bitcoinwallet.Wallet

  describe "transactions" do
    alias Bitcoinwallet.Wallet.Transaction

    import Bitcoinwallet.WalletFixtures

    @invalid_attrs %{date: nil, symbol: nil, amount: nil, price: nil}

    test "list_transactions/0 returns all transactions" do
      transaction = transaction_fixture()
      assert Wallet.list_transactions() == [transaction]
    end

    test "get_transaction!/1 returns the transaction with given id" do
      transaction = transaction_fixture()
      assert Wallet.get_transaction!(transaction.id) == transaction
    end

    test "create_transaction/1 with valid data creates a transaction" do
      valid_attrs = %{date: ~D[2025-02-08], symbol: "some symbol", amount: 120.5, price: 120.5}

      assert {:ok, %Transaction{} = transaction} = Wallet.create_transaction(valid_attrs)
      assert transaction.date == ~D[2025-02-08]
      assert transaction.symbol == "some symbol"
      assert transaction.amount == 120.5
      assert transaction.price == 120.5
    end

    test "create_transaction/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Wallet.create_transaction(@invalid_attrs)
    end

    test "update_transaction/2 with valid data updates the transaction" do
      transaction = transaction_fixture()
      update_attrs = %{date: ~D[2025-02-09], symbol: "some updated symbol", amount: 456.7, price: 456.7}

      assert {:ok, %Transaction{} = transaction} = Wallet.update_transaction(transaction, update_attrs)
      assert transaction.date == ~D[2025-02-09]
      assert transaction.symbol == "some updated symbol"
      assert transaction.amount == 456.7
      assert transaction.price == 456.7
    end

    test "update_transaction/2 with invalid data returns error changeset" do
      transaction = transaction_fixture()
      assert {:error, %Ecto.Changeset{}} = Wallet.update_transaction(transaction, @invalid_attrs)
      assert transaction == Wallet.get_transaction!(transaction.id)
    end

    test "delete_transaction/1 deletes the transaction" do
      transaction = transaction_fixture()
      assert {:ok, %Transaction{}} = Wallet.delete_transaction(transaction)
      assert_raise Ecto.NoResultsError, fn -> Wallet.get_transaction!(transaction.id) end
    end

    test "change_transaction/1 returns a transaction changeset" do
      transaction = transaction_fixture()
      assert %Ecto.Changeset{} = Wallet.change_transaction(transaction)
    end
  end
end

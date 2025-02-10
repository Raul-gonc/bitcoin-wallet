defmodule Bitcoinwallet.WalletFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Bitcoinwallet.Wallet` context.
  """

  @doc """
  Generate a transaction.
  """
  def transaction_fixture(attrs \\ %{}) do
    {:ok, transaction} =
      attrs
      |> Enum.into(%{
        amount: 120.5,
        date: ~D[2025-02-08],
        price: 120.5,
        symbol: "some symbol"
      })
      |> Bitcoinwallet.Wallet.create_transaction()

    transaction
  end
end

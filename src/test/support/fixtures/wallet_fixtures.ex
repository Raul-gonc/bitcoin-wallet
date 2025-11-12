defmodule Bitcoinwallet.WalletFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Bitcoinwallet.Wallet` context.
  """

  @doc """
  Generate a transaction.
  """
  def transaction_fixture(attrs \\ %{}) do
    # Ensure we have a valid user_id
    user = Bitcoinwallet.AccountsFixtures.user_fixture()
    
    {:ok, transaction} =
      attrs
      |> Enum.into(%{
        user_id: user.id,
        amount: 120.5,
        date: ~D[2025-02-08],
        price: 120.5,
        symbol: "bitcoin"
      })
      |> then(fn params ->
        Bitcoinwallet.Wallet.create_transaction(
          params.user_id,
          params.symbol,
          params.amount,
          params.price
        )
      end)

    transaction
  end
end

defmodule BitcoinwalletWeb.WalletController do
  use BitcoinwalletWeb, :controller
  alias Bitcoinwallet.Wallet
  alias Bitcoinwallet.Auth.Guardian

  # Fetches the user's wallet transactions
  def index(conn, _params) do
    IO.inspect(conn.assigns, label: "Conn assigns:")
    token = Guardian.get_token_from_header(conn)
    IO.inspect(token, label: "Conn assigns:")
    {:ok, user} = Guardian.get_user_from_token(token)
    IO.inspect(user, label: "Usuário autenticado:")
    transactions = Wallet.list_transactions_by_user(user.id)
    conn |> json(transactions)
  end

  # Adds a buy transaction to the wallet
  def buy(conn, %{"symbol" => symbol, "amount" => amount}) do
    token = Guardian.get_token_from_header(conn)
    {:ok, user} = Guardian.get_user_from_token(token)

    case Bitcoinwallet.CoinAPI.get_coin(symbol) do
      {:ok, coin} ->
        IO.inspect(user, label: "User - w")
        IO.inspect(coin, label: "coin - w")
        price = coin["current_price"]
        IO.inspect(price, label: "price - w")
        Wallet.create_transaction(user.id, symbol, amount, price)
        conn |> json(%{message: "Transaction created"})
      {:error, reason} ->
        conn |> put_status(:bad_request) |> json(%{error: reason})
    end
  end

  # Adds a sell transaction to the wallet
  def sell(conn, %{"symbol" => symbol, "amount" => amount}) do
    token = Guardian.get_token_from_header(conn)
    {:ok, user} = Guardian.get_user_from_token(token)
    case Bitcoinwallet.CoinAPI.get_coin(symbol) do
      {:ok, coin} ->
        price = coin["current_price"]
        Wallet.create_transaction(user.id, symbol, -amount, price)
        conn |> json(%{message: "Transaction created"})
      {:error, reason} ->
        conn |> put_status(:bad_request) |> json(%{error: reason})
    end
  end

  # Calculates the user's wallet balance
  def balance(conn, _params) do
    token = Guardian.get_token_from_header(conn)
    {:ok, user} = Guardian.get_user_from_token(token)
    balance = Wallet.calculate_balance(user.id)

    balance_with_prices = Enum.map(balance, fn %{symbol: symbol, total: total} ->
      {:ok, coin} = Bitcoinwallet.CoinAPI.get_coin(symbol)
      IO.inspect(coin, label: "coin info:")
      price = coin["current_price"]
      IO.inspect(price, label: "price info:")
      converted_value = total * price

      %{symbol: symbol, total: total, current_price: price, converted_value: converted_value}
    end)

    conn |> json(%{balance: balance_with_prices})
  end
end

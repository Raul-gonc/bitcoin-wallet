defmodule BitcoinwalletWeb.WalletController do
  use BitcoinwalletWeb, :controller
  require Logger
  alias Bitcoinwallet.Wallet
  alias Guardian.Plug

  def index(conn, _params) do
    user = Plug.current_resource(conn)
    Logger.debug("Fetching transactions for user: #{user.id}")
    transactions = Wallet.list_transactions_by_user(user.id)
    conn |> json(transactions)
  end

  def buy(conn, %{"symbol" => symbol, "amount" => amount}) do
    user = Plug.current_resource(conn)

    case Bitcoinwallet.CoinAPI.get_coin(symbol) do
      {:ok, coin} ->
        price = coin["current_price"]
        Logger.info("User #{user.id} buying #{amount} of #{symbol} at #{price}")
        Wallet.create_transaction(user.id, symbol, amount, price)
        conn |> json(%{message: "Transaction created"})
      {:error, reason} ->
        Logger.warning("Failed to buy #{symbol}: #{inspect(reason)}")
        conn |> put_status(:bad_request) |> json(%{error: reason})
    end
  end

  def sell(conn, %{"symbol" => symbol, "amount" => amount}) do
    user = Plug.current_resource(conn)
    
    case Wallet.can_sell?(user.id, symbol, amount) do
      {:ok, _balance} ->
        case Bitcoinwallet.CoinAPI.get_coin(symbol) do
          {:ok, coin} ->
            price = coin["current_price"]
            Logger.info("User #{user.id} selling #{amount} of #{symbol} at #{price}")
            Wallet.create_transaction(user.id, symbol, -amount, price)
            conn |> json(%{message: "Transaction created"})
          {:error, reason} ->
            Logger.warning("Failed to get coin price for #{symbol}: #{inspect(reason)}")
            conn |> put_status(:bad_request) |> json(%{error: reason})
        end
      {:error, reason} ->
        Logger.warning("User #{user.id} cannot sell #{symbol}: #{reason}")
        conn |> put_status(:bad_request) |> json(%{error: reason})
    end
  end

  def balance(conn, _params) do
    user = Plug.current_resource(conn)
    balance = Wallet.calculate_balance(user.id)

    symbols = Enum.map(balance, & &1.symbol)
    
    prices_result = Enum.reduce_while(symbols, {:ok, %{}}, fn symbol, {:ok, acc} ->
      case Bitcoinwallet.CoinAPI.get_coin(symbol) do
        {:ok, coin} -> {:cont, {:ok, Map.put(acc, symbol, coin["current_price"])}}
        {:error, reason} -> {:halt, {:error, reason}}
      end
    end)

    case prices_result do
      {:ok, prices} ->
        balance_with_prices = Enum.map(balance, fn %{symbol: symbol, total: total} ->
          price = Map.get(prices, symbol)
          converted_value = total * price
          Logger.debug("Balance for #{symbol}: #{total} (value: #{converted_value})")
          %{symbol: symbol, total: total, current_price: price, converted_value: converted_value}
        end)
        
        conn |> json(%{balance: balance_with_prices})
      {:error, reason} ->
        Logger.error("Failed to fetch prices: #{inspect(reason)}")
        conn |> put_status(:bad_request) |> json(%{error: reason})
    end
  end
end

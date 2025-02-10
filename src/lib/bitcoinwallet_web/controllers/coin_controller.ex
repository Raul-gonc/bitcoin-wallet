defmodule BitcoinwalletWeb.CoinController do
  use BitcoinwalletWeb, :controller
  alias Bitcoinwallet.CoinAPI

  # Fetches the list of cryptocurrencies
  def index(conn, _params) do
    case CoinAPI.get_coins() do
      {:ok, coins} -> conn |> json(coins)
      {:error, reason} -> conn |> put_status(:bad_request) |> json(%{error: reason})
    end
  end

  # Fetches details of a specific cryptocurrency
  def show(conn, %{"symbol" => symbol}) do
    case CoinAPI.get_coin(symbol) do
      {:ok, coin} ->
        IO.inspect(coin, label: "coin info:")
        conn |> json(coin)

      {:error, reason} ->
        conn |> put_status(:bad_request) |> json(%{error: reason})
    end
  end

end

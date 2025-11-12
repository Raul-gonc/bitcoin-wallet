defmodule Bitcoinwallet.CoinAPI do
  require Logger
  @base_url "https://api.coingecko.com/api/v3"
  @cache_expiry 600  # Segundos
  @cache_key :crypto_list

  # Busca lista de criptomoedas, utilizando cache
  def get_coins do
    case Cachex.fetch(:crypto_cache, @cache_key, fn _key ->
      url = "#{@base_url}/coins/markets?vs_currency=usd"
      Logger.info("Fetching coins from API: #{url}")
      
      case HTTPoison.get(url) |> handle_response() do
        {:ok, data} ->
          timestamp = System.system_time(:second)
          {:commit, %{timestamp: timestamp, data: data}, ttl: :timer.seconds(@cache_expiry)}
        error ->
          Logger.error("Failed to fetch coins: #{inspect(error)}")
          {:ignore, error}
      end
    end) do
      {:ok, %{data: data}} -> {:ok, data}
      {:commit, %{data: data}} -> {:ok, data}
      {:commit, %{data: data}, _opts} -> {:ok, data}
      {:error, reason} -> {:error, reason}
      error -> error
    end
  end

  # Busca detalhes de uma moeda (do cache ou API se data for fornecida)
  def get_coin(symbol, date \\ nil) do
    if date do
      fetch_coin_from_api(symbol, date)
    else
      fetch_coin_from_cache(symbol)
    end
  end



  # Busca uma moeda específica do cache
  defp fetch_coin_from_cache(symbol) do
    case get_coins() do
      {:ok, coins} ->
        case Enum.find(coins, fn coin -> coin["id"] == symbol end) do
          nil -> 
            Logger.warning("Coin not found in cache: #{symbol}")
            {:error, "Coin not found in cache"}
          coin -> 
            {:ok, coin}
        end

      error -> error
    end
  end

  # Busca uma moeda diretamente da API quando uma data é fornecida
  defp fetch_coin_from_api(symbol, date) do
    url = "#{@base_url}/coins/#{symbol}/history?date=#{date}"

    Logger.info("Fetching coin history from API: #{url}")

    HTTPoison.get(url)
    |> handle_response()
  end

  # Trata resposta da API
  defp handle_response({:ok, %{status_code: 200, body: body}}) do
    {:ok, Jason.decode!(body)}
  end

  defp handle_response({:ok, %{status_code: status_code}}) do
    {:error, "API retornou status #{status_code}"}
  end

  defp handle_response({:error, reason}) do
    {:error, reason}
  end
end

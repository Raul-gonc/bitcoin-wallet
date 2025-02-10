defmodule Bitcoinwallet.CoinAPI do
  require Logger
  @base_url "https://api.coingecko.com/api/v3"
  @cache_expiry 600  # Segundos
  @cache_key :crypto_list

  # Busca lista de criptomoedas, utilizando cache
  def get_coins do
    case Cachex.get(:crypto_cache, @cache_key) do
      {:ok, nil} -> fetch_and_cache_coins()
      {:ok, :no_cache} -> fetch_and_cache_coins()
      {:ok, %{timestamp: timestamp, data: data}} ->
        if is_expired?(timestamp) do
          fetch_and_cache_coins()
        else
          {:ok, data}  # Retorna do cache
        end
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

  # Obtém os dados da API e armazena no cache
  defp fetch_and_cache_coins do
    url = "#{@base_url}/coins/markets?vs_currency=usd"
    IO.inspect(url, label: "api acessada:")
    case HTTPoison.get(url) |> handle_response() do
      {:ok, data} ->
        timestamp = System.system_time(:second)
        Cachex.put(:crypto_cache, @cache_key, %{timestamp: timestamp, data: data})
        {:ok, data}

      error -> error
    end
  end

  # Busca uma moeda específica do cache
  defp fetch_coin_from_cache(symbol) do
    case get_coins() do
      {:ok, coins} ->
        case Enum.find(coins, fn coin -> coin["id"] == symbol end) do
          nil -> {:error, "Moeda não encontrada no cache"}
          coin -> {:ok, coin}
        end

      error -> error
    end
  end

  # Busca uma moeda diretamente da API quando uma data é fornecida
  defp fetch_coin_from_api(symbol, date) do
    url = "#{@base_url}/coins/#{symbol}/history?date=#{date}"

    Logger.info("🔍 Chamando API para histórico: #{url}")

    HTTPoison.get(url)
    |> handle_response()
  end

  # Verifica se o cache expirou
  defp is_expired?(timestamp) do
    System.system_time(:second) - timestamp > @cache_expiry
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

defmodule Bitcoinwallet.Wallet do
  @moduledoc """
  The Wallet context.
  """

  import Ecto.Query, warn: false
  alias Bitcoinwallet.Repo

  alias Bitcoinwallet.Wallet.Transaction


  @doc """
  Returns the list of transactions.

  ## Examples

      iex> list_transactions()
      [%Transaction{}, ...]

  """
  def list_transactions do
    Repo.all(Transaction)
  end

  @doc """
  Gets a single transaction.

  Raises `Ecto.NoResultsError` if the Transaction does not exist.

  ## Examples

      iex> get_transaction!(123)
      %Transaction{}

      iex> get_transaction!(456)
      ** (Ecto.NoResultsError)

  """
  def get_transaction!(id), do: Repo.get!(Transaction, id)

  @doc """
  Creates a transaction.

  ## Examples

      iex> create_transaction(%{field: value})
      {:ok, %Transaction{}}

      iex> create_transaction(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_transaction(attrs \\ %{}) do
    %Transaction{}
    |> Transaction.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a transaction.

  ## Examples

      iex> update_transaction(transaction, %{field: new_value})
      {:ok, %Transaction{}}

      iex> update_transaction(transaction, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_transaction(%Transaction{} = transaction, attrs) do
    transaction
    |> Transaction.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a transaction.

  ## Examples

      iex> delete_transaction(transaction)
      {:ok, %Transaction{}}

      iex> delete_transaction(transaction)
      {:error, %Ecto.Changeset{}}

  """
  def delete_transaction(%Transaction{} = transaction) do
    Repo.delete(transaction)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking transaction changes.

  ## Examples

      iex> change_transaction(transaction)
      %Ecto.Changeset{data: %Transaction{}}

  """
  def change_transaction(%Transaction{} = transaction, attrs \\ %{}) do
    Transaction.changeset(transaction, attrs)
  end

  def create_transaction(user_id, symbol, amount, price) do
    # Converte a string de data para o tipo Date
    date_parsed = Date.utc_today()

    %Transaction{}
    |> Transaction.changeset(%{
      user_id: user_id,
      symbol: symbol,
      amount: amount,
      price: price,
      date: date_parsed
    })
    |> Repo.insert()
  end

   # Lists all transactions for a user
   def list_transactions_by_user(user_id) do
    query = from t in Transaction, where: t.user_id == ^user_id
    Repo.all(query)
  end

  # Lists transactions within a specific period
  def list_transactions_in_period(user_id, start_date, end_date) do
    {:ok, start_date_parsed} = parse_date(start_date)
    {:ok, end_date_parsed} = parse_date(end_date)
    query =
      from t in Transaction,
        where: t.user_id == ^user_id and t.date >= ^start_date_parsed and t.date <= ^end_date_parsed
    Repo.all(query)
  end

  # Calculates the user's wallet balance
  def calculate_balance(user_id) do
    query = from t in Transaction,
            where: t.user_id == ^user_id,
            group_by: t.symbol,
            select: %{symbol: t.symbol, total: sum(t.amount)}
    Repo.all(query)
  end

  # Calculates the user's total profit/loss
  def calculate_profit(user_id) do
    query = from t in Transaction, where: t.user_id == ^user_id, select: sum(t.amount * t.price)
    Repo.one(query) || 0.0
  end

  defp parse_date(date_string) do
    case String.split(date_string, ["-", "/"]) do
      [day, month, year] ->
        # Converte para o formato Date
        Date.new(String.to_integer(year), String.to_integer(month), String.to_integer(day))
      _ ->
        {:error, "Invalid date format. Use dd-mm-yyyy or dd/mm/yyyy"}
    end
  end
end

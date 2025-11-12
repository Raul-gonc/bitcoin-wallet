defmodule BitcoinwalletWeb.AuthController do
  use BitcoinwalletWeb, :controller
  require Logger
  alias Bitcoinwallet.Accounts
  alias Bitcoinwallet.Auth.Guardian

  def register(conn, %{"email" => email, "password" => password}) do
    with {:ok, _email} <- validate_email(email),
         {:ok, _password} <- validate_password(password),
         {:ok, user} <- Accounts.create_user(%{email: email, password: password}),
         {:ok, token} <- Guardian.token_for_user(user) do
      Logger.info("New user registered: #{email}")
      conn
      |> put_status(:created)
      |> json(%{token: token})
    else
      {:error, :invalid_email} ->
        conn |> put_status(:bad_request) |> json(%{error: "Invalid email format"})
      {:error, :weak_password} ->
        conn |> put_status(:bad_request) |> json(%{error: "Password must be at least 8 characters long"})
      {:error, changeset} ->
        conn |> put_status(:bad_request) |> json(%{error: changeset.errors})
    end
  end

  defp validate_email(email) do
    if String.match?(email, ~r/^[^\s]+@[^\s]+\.[^\s]+$/),
      do: {:ok, email},
      else: {:error, :invalid_email}
  end

  defp validate_password(password) do
    if String.length(password) >= 8,
      do: {:ok, password},
      else: {:error, :weak_password}
  end

  def login(conn, %{"email" => email, "password" => password}) do
    case Accounts.get_user_by_email(email) do
      nil ->
        Logger.warning("Login attempt for non-existent user: #{email}")
        conn
        |> put_status(:unauthorized)
        |> json(%{error: "Invalid credentials"})

      user ->
        if Argon2.verify_pass(password, user.password_hash) do
          case Guardian.token_for_user(user) do
            {:ok, token} ->
              Logger.info("User logged in successfully: #{email}")
              conn
              |> json(%{token: token})

            {:error, reason} ->
              Logger.error("Error generating token for user #{email}: #{inspect(reason)}")
              conn
              |> put_status(:internal_server_error)
              |> json(%{error: "Error generating token", reason: reason})
          end
        else
          Logger.warning("Failed login attempt for user: #{email}")
          conn
          |> put_status(:unauthorized)
          |> json(%{error: "Invalid credentials"})
        end
    end
  end

  def logout(conn, _params) do
    conn |> json(%{message: "Logged out"})
  end
end

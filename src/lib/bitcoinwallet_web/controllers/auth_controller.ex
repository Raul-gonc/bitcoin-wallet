defmodule BitcoinwalletWeb.AuthController do
  use BitcoinwalletWeb, :controller
  alias Bitcoinwallet.Accounts
  alias Bitcoinwallet.Auth.Guardian

  # Registers a new user
  def register(conn, %{"email" => email, "password" => password}) do
    case Accounts.create_user(%{email: email, password: password}) do
      {:ok, user} ->
        token = Guardian.token_for_user(user)

        conn
        |> put_status(:created)
        |> json(%{token: token})

      {:error, changeset} ->
        conn
        |> put_status(:bad_request)
        |> json(%{error: changeset.errors})
    end
  end

  # Authenticates a user and generates a JWT token
  def login(conn, %{"email" => email, "password" => password}) do
    case Accounts.get_user_by_email(email) do
      nil ->
        conn
        |> put_status(:unauthorized)
        |> json(%{error: "Invalid credentials"})

      user ->
        if Argon2.verify_pass(password, user.password_hash) do
          IO.inspect(user, label: "User")
          case Guardian.token_for_user(user) do
            {:ok, token} ->
              conn
              |> json(%{token: token})

            {:error, reason} ->
              conn
              |> put_status(:internal_server_error)
              |> json(%{error: "Error generating token", reason: reason})
          end
        else
          conn
          |> put_status(:unauthorized)
          |> json(%{error: "Invalid credentials"})
        end
    end
  end


  # Logs out the user (placeholder implementation)
  def logout(conn, _params) do
    conn |> json(%{message: "Logged out"})
  end
end

defmodule Bitcoinwallet.Auth.Guardian do
  use Guardian, otp_app: :bitcoinwallet

  def subject_for_token(user, _claims) do
    {:ok, to_string(user.id)}
  end

  def resource_from_claims(claims) do
    require Logger
    Logger.debug("Processing claims for user authentication")
    
    case claims["sub"] do
      nil -> {:error, :not_found}
      user_id ->
        case Bitcoinwallet.Accounts.get_user!(user_id) do
          nil -> {:error, :not_found}
          user ->
            Logger.debug("User #{user.id} authenticated successfully")
            {:ok, user}
        end
    end
  end

  # Generates a JWT token for the user
  def token_for_user(user) do
    case Bitcoinwallet.Auth.Guardian.encode_and_sign(user) do
      {:ok, token, _claims} ->
        {:ok, token}
      {:error, reason} ->
        {:error, reason}
    end
  end

  # Validates the JWT token and returns the associated user
  def get_user_from_token(token) do
    case Bitcoinwallet.Auth.Guardian.decode_and_verify(token) do
      {:ok, claims} ->
        user_id = claims["sub"]

        case Bitcoinwallet.Accounts.get_user!(user_id) do
          %Bitcoinwallet.Accounts.User{} = user ->
            {:ok, user}
          nil ->
            {:error, "User not found"}
        end

      {:error, reason} ->
        {:error, "Invalid token: #{reason}"}
    end
  end

  def get_token_from_header(conn) do
    conn
    |> Plug.Conn.get_req_header("authorization")
    |> List.first()
    |> case do
      "Bearer " <> token -> token
      _ -> nil
    end
  end
end

defmodule BitcoinwalletWeb.Router do
  use BitcoinwalletWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :auth do
    plug Guardian.Plug.Pipeline, module: Bitcoinwallet.Auth.Guardian, error_handler: BitcoinwalletWeb.AuthErrorHandler
    plug Guardian.Plug.VerifyHeader, scheme: "Bearer"
    plug Guardian.Plug.LoadResource, allow_blank: false
  end

  scope "/api", BitcoinwalletWeb do
    pipe_through :api

    post "/register", AuthController, :register
    post "/login", AuthController, :login
    post "/logout", AuthController, :logout

    get "/coins", CoinController, :index
    get "/coins/:symbol", CoinController, :show
  end

  scope "/api", BitcoinwalletWeb do
    pipe_through [:api, :auth]

    get "/wallet", WalletController, :index
    post "/wallet/buy", WalletController, :buy
    post "/wallet/sell", WalletController, :sell
    get "/wallet/balance", WalletController, :balance
  end

  if Application.compile_env(:bitcoinwallet, :dev_routes) do
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through [:fetch_session, :protect_from_forgery]

      live_dashboard "/dashboard", metrics: BitcoinwalletWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end

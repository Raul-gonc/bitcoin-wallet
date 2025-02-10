defmodule BitcoinwalletWeb.Router do
  use BitcoinwalletWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :auth do
    plug Guardian.Plug.Pipeline, module: Bitcoinwallet.Auth.Guardian, error_handler: BitcoinwalletWeb.AuthErrorHandler
    plug Guardian.Plug.VerifyHeader, scheme: "Bearer"
  end


  # Public routes (no authentication required)
  scope "/api", BitcoinwalletWeb do
    pipe_through :api

    post "/register", AuthController, :register
    post "/login", AuthController, :login
    post "/logout", AuthController, :logout

    get "/coins", CoinController, :index
    get "/coins/:symbol", CoinController, :show
  end

  # Authenticated routes (require JWT token)
  scope "/api", BitcoinwalletWeb do
    pipe_through [:api, :auth]
  end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:bitcoinwallet, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through [:fetch_session, :protect_from_forgery]

      live_dashboard "/dashboard", metrics: BitcoinwalletWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end

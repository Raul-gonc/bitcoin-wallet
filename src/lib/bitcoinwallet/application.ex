defmodule Bitcoinwallet.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      BitcoinwalletWeb.Telemetry,
      Bitcoinwallet.Repo,
      {DNSCluster, query: Application.get_env(:bitcoinwallet, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Bitcoinwallet.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Bitcoinwallet.Finch},
      # Start a worker by calling: Bitcoinwallet.Worker.start_link(arg)
      # {Bitcoinwallet.Worker, arg},
      # Start to serve requests, typically the last entry
      BitcoinwalletWeb.Endpoint,
      Bitcoinwallet.Supervisor
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Bitcoinwallet.Application]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    BitcoinwalletWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end

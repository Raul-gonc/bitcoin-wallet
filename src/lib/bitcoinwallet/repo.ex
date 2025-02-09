defmodule Bitcoinwallet.Repo do
  use Ecto.Repo,
    otp_app: :bitcoinwallet,
    adapter: Ecto.Adapters.Postgres
end

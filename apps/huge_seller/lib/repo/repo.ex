defmodule HugeSeller.Repo do
  use Ecto.Repo,
    otp_app: :huge_seller,
    adapter: Ecto.Adapters.Postgres
end

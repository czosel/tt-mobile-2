defmodule TtMobile.Repo do
  use Ecto.Repo,
    otp_app: :tt_mobile,
    adapter: Ecto.Adapters.Postgres
end

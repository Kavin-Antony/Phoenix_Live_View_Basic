defmodule LvBasics.Repo do
  use Ecto.Repo,
    otp_app: :lv_basics,
    adapter: Ecto.Adapters.Postgres
end

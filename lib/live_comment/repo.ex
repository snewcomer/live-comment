defmodule LiveComment.Repo do
  use Ecto.Repo,
    otp_app: :live_comment,
    adapter: Ecto.Adapters.Postgres
end

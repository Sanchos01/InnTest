defmodule InnTest.Repo do
  use Ecto.Repo,
    otp_app: :inn_test,
    adapter: Sqlite.Ecto2
end

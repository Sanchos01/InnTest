# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :inn_test, InnTest.Repo,
  adapter: Sqlite.Ecto2,
  database: "inn_test.sqlite3"

config :inn_test,
  ecto_repos: [InnTest.Repo]

# Configures the endpoint
config :inn_test, InnTestWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "Q9LKojr3euYuMSjSoKlljkiCb473soXuASrOr/gnkXqBhHl/J1dXJ7elmXXvP2V+",
  render_errors: [view: InnTestWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: InnTest.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"

# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :live_comment,
  ecto_repos: [LiveComment.Repo]

# Configures the endpoint
config :live_comment, LiveCommentWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "ynUXsjLtHvM4nEwah/E7VFYbcc31LtaarzW9QGNQCuTI777HIodCeabCYIxYofX/",
  render_errors: [view: LiveCommentWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: LiveComment.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :live_comment, LiveCommentWeb.Endpoint,
 live_view: [
   signing_salt: "SB18X6kXFHXjG4evDO/M0sLzDoZ8AwmJ"
 ]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"

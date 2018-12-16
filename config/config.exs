# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :robotica_face,
  ecto_repos: [RoboticaFace.Repo]

# Configures the endpoint
config :robotica_face, RoboticaFaceWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "c7D1XBwlgd9KYS/HKKqH4el7ofNFtOCv8rtvwy7Zc8IQ0Ubq22/Bgnb16D8n/wPL",
  render_errors: [view: RoboticaFaceWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: RoboticaFace.PubSub, adapter: Phoenix.PubSub.PG2]

config :robotica_face, RoboticaFaceWeb.Auth.AuthAccessPipeline,
  module: RoboticaFace.Auth.Guardian,
  error_handler: RoboticaFaceWeb.Auth.AuthErrorHandler

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import secrets.
import_config "secrets.exs"

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"

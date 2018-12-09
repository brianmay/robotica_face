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

config :joken,
  rs256: [
    signer_alg: "RS256",
    key_pem: """
    -----BEGIN CERTIFICATE-----
    MIIDJjCCAg6gAwIBAgIIHjqNyx42LJgwDQYJKoZIhvcNAQEFBQAwNjE0MDIGA1UE
    AxMrZmVkZXJhdGVkLXNpZ25vbi5zeXN0ZW0uZ3NlcnZpY2VhY2NvdW50LmNvbTAe
    Fw0xODEyMDMxNDQ5MTNaFw0xODEyMjAwMzA0MTNaMDYxNDAyBgNVBAMTK2ZlZGVy
    YXRlZC1zaWdub24uc3lzdGVtLmdzZXJ2aWNlYWNjb3VudC5jb20wggEiMA0GCSqG
    SIb3DQEBAQUAA4IBDwAwggEKAoIBAQCUPM6L+urBOw4LZRMMoI8tAEurkGF2ZE/c
    AQWC2igQ0B2bBaHT+2IC1wssGlJ5ziT0xymztzHcb+5cGb3LdOAIdX3K4mdbGQvc
    ME6ule51JBziD8HP9o5TeNXryN0rfvm14por0iYm0WM9k1WirpdX1RL4C/YM1inp
    MkfPsJLOHDPtDql0vtCyHcytGoDBnEhtYjsN3eNk7V//n1sTuO6/D6mAccGwVWNN
    VvjXfa1naL/wPw2K4cGD9lVUl2SfehcBBkHjolHo+5TJNQSgacFbVlmFoKndOgwt
    3Iolmcl9eoA+eITu36iYw5BlLtUVo8BKXJyc8vfOfIEt7J67LD27AgMBAAGjODA2
    MAwGA1UdEwEB/wQCMAAwDgYDVR0PAQH/BAQDAgeAMBYGA1UdJQEB/wQMMAoGCCsG
    AQUFBwMCMA0GCSqGSIb3DQEBBQUAA4IBAQAD+Jguiz7SCk298W1NUIyYrttoefr1
    kbFCrZShTh28PLbhJPb8rkO4FzylgTenDV5blrK+gg6RWnEHbSrIL/JXcAKMrLI4
    NWINAsWWJu66qm65iRvfVS4i4lHN+XxDDKMewUq3Eq+NmJXLDLMkPzlDiYUstf2n
    0xu2DddeJiXHQfdNLWo8BskVwYOg+k5sqv7w4lwxzNWoVAqe3aDkCoPiMAnXogCT
    dxq8TDITYuX+PVHMPPNp4fO+s3rqETKmTVSiu36X0/RHo1+MmLmEiFgi5Qu0cRh3
    2Y9ekOhRYn2itabUYH7y7Vn1QwyYHerwE4XXdUgGCh+x28EkQ+TYDH58
    -----END CERTIFICATE-----
    """
  ]

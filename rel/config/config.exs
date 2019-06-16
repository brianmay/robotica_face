use Mix.Config

config :robotica_face,
  api_username: System.get_env("GOOGLE_USERNAME"),
  api_password: System.get_env("GOOGLE_PASSWORD"),
  mqtt_host: System.get_env("MQTT_HOST"),
  mqtt_port: String.to_integer(System.get_env("MQTT_PORT") || "8883"),
  ca_cert_file: System.get_env("CA_CERT_FILE"),
  mqtt_user_name: System.get_env("MQTT_USER_NAME"),
  mqtt_password: System.get_env("MQTT_PASSWORD")

config :robotica_face, RoboticaFace.Repo, url: System.get_env("DATABASE_URL")

config :robotica_face, RoboticaFaceWeb.Endpoint,
  secret_key_base: System.get_env("SECRET_KEY_BASE")

config :robotica_face, RoboticaFace.Auth.Guardian,
  issuer: "robotica_face",
  secret_key: System.get_env("GUARDIAN_SECRET")

if System.get_env("IPV6") != nil do
  config :robotica_face, RoboticaFace.Repo, socket_options: [:inet6]
end

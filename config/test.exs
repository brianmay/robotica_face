use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :robotica_face, RoboticaFaceWeb.Endpoint,
  http: [port: 4002],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :robotica_face, RoboticaFace.Repo,
  username: "postgres",
  password: "postgres",
  database: "robotica_face_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

defmodule RoboticaFace.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def get_tortoise_client_id do
    {:ok, hostname} = :inet.gethostname()
    hostname = to_string(hostname)
    "robotica_face-#{hostname}"
  end

  def start(_type, _args) do
    # List all child processes to be supervised
    children = [
      # Start the Ecto repository
      RoboticaFace.Repo,
      # Start the endpoint when the application starts
      RoboticaFaceWeb.Endpoint,
      {Tortoise.Connection,
       client_id: get_tortoise_client_id(),
       handler: {RoboticaFace.Handler, []},
       server: {Tortoise.Transport.Tcp, host: "localhost", port: 1883},
       subscriptions: [
         {"stat/sonoff/POWER", 0},
         {"schedule/#", 0}
       ]},
      {RoboticaFace.Schedule, name: :schedule}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: RoboticaFace.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    RoboticaFaceWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end

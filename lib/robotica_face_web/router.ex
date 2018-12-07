defmodule RoboticaFaceWeb.Router do
  use RoboticaFaceWeb, :router

  @api_username Application.get_env(:robotica_face, :api_username)
  @api_password Application.get_env(:robotica_face, :api_password)

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug BasicAuth, username: @api_username, password: @api_password
  end

  scope "/", RoboticaFaceWeb do
    pipe_through :browser

    get "/", PageController, :index
  end

  scope "/api", RoboticaFaceWeb do
    pipe_through :api

    post "/", ApiController, :index
  end
end

defmodule RoboticaFaceWeb.PageController do
  use RoboticaFaceWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def schedule(conn, _params) do
    schedule = RoboticaFace.Schedule.get_schedule(:schedule)
    render(conn, "schedule.html", schedule: schedule)
  end
end

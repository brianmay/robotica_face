defmodule RoboticaFaceWeb.ScheduleController do
  use RoboticaFaceWeb, :controller

  def upcoming_list(conn, _params) do
    schedule = RoboticaFace.Schedule.get_schedule(:schedule)
    render(conn, "schedule.html", schedule: schedule)
  end
end

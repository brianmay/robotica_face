defmodule RoboticaFaceWeb.ScheduleController do
  use RoboticaFaceWeb, :controller

  def upcoming_list(conn, params) do
    hostname = params["hostname"]

    case RoboticaFace.Schedule.get_schedule(:schedule, hostname) do
      {:ok, schedule} ->
        render(conn, "schedule.html", schedule: schedule, hostname: hostname)

      :error ->
        conn
        |> put_view(RoboticaFaceWeb.ErrorView)
        |> render("404.html")
    end
  end

  def host_list(conn, _params) do
    host_list = RoboticaFace.Schedule.get_host_list(:schedule)
    render(conn, "host_list.html", host_list: host_list)
  end

  defp get_task(hostname, task_id) do
    steps = RoboticaFace.Schedule.get_tasks_by_id(:schedule, hostname, task_id)

    case steps do
      {:ok, [head | _]} -> hd(head["tasks"])
      {:ok, _} -> nil
      :error -> :error
    end
  end

  def mark(conn, params) do
    id = params["task_id"]
    hostname = params["hostname"]
    status = params["status"]
    task = get_task(hostname, id)

    case task do
      nil ->
        conn
        |> put_view(RoboticaFaceWeb.ErrorView)
        |> render("404.html")

      _ ->
        do_mark(conn, hostname, task, status)
    end
  end

  defp do_mark(conn, hostname, task, status) do
    result = RoboticaFace.Mqtt.mark_task(task, status)

    case result do
      :ok ->
        conn
        |> put_flash(:info, "Mark published.")
        |> redirect(to: Routes.schedule_path(conn, :upcoming_list, hostname))

      :error ->
        conn
        |> put_flash(:info, "Mark NOT published.")
        |> redirect(to: Routes.schedule_path(conn, :upcoming_list, hostname))
    end
  end
end

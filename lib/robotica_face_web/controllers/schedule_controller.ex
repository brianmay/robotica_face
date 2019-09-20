defmodule RoboticaFaceWeb.ScheduleController do
  use RoboticaFaceWeb, :controller

  def upcoming_list(conn, _params) do
    case RoboticaFace.Schedule.get_schedule(:schedule) do
      {:ok, schedule} ->
        render(conn, "schedule.html", schedule: schedule)

      :error ->
        conn
        |> put_view(RoboticaFaceWeb.ErrorView)
        |> render("404.html")
    end
  end

  defp get_task(task_id) do
    steps = RoboticaFace.Schedule.get_tasks_by_id(:schedule, task_id)

    case steps do
      {:ok, [head | _]} -> hd(head.tasks)
      {:ok, _} -> nil
      :error -> :error
    end
  end

  def mark(conn, params) do
    id = params["task_id"]
    status = params["status"]
    task = get_task(id)

    case task do
      nil ->
        conn
        |> put_view(RoboticaFaceWeb.ErrorView)
        |> render("404.html")

      _ ->
        do_mark(conn, task, status)
    end
  end

  defp do_mark(conn, task, status) do
    result = RoboticaFace.Mark.mark_task(task, status)

    case result do
      :ok ->
        conn
        |> put_flash(:info, "Mark published.")
        |> redirect(to: Routes.schedule_path(conn, :upcoming_list))

      :error ->
        conn
        |> put_flash(:info, "Mark NOT published.")
        |> redirect(to: Routes.schedule_path(conn, :upcoming_list))
    end
  end
end

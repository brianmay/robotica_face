defmodule RoboticaFaceWeb.ScheduleController do
  use RoboticaFaceWeb, :controller

  def upcoming_list(conn, _params) do
    schedule = RoboticaFace.Schedule.get_schedule(:schedule)
    render(conn, "schedule.html", schedule: schedule)
  end

  defp get_task_frequency(task_id) do
    steps = RoboticaFace.Schedule.get_tasks_by_id(:schedule, task_id)

    case steps do
      [head | _] -> hd(head["tasks"])["frequency"]
      _ -> nil
    end
  end

  defp tomorrow(date) do
     Calendar.Date.next_day!(date)
  end

  def next_monday(date) do
    # M 1 --> +7
    # T 2 --> +6
    # W 3 --> +5
    # T 4 --> +4
    # F 5 --> +3
    # S 6 --> +2
    # S 7 --> +1

    day_of_week = Date.day_of_week(date)
    add_days = 7 - day_of_week + 1
    Calendar.Date.add!(date, add_days)
  end

  def midnight_utc(date) do
    Calendar.DateTime.from_date_and_time_and_zone!(date, ~T[00:00:00], "Australia/Melbourne")
    |> Calendar.DateTime.shift_zone!("UTC")
  end

  def mark(conn, params) do
    id = params["task_id"]
    frequency = get_task_frequency(id)

    now = Calendar.DateTime.now!("Australia/Melbourne")
    midnight = tomorrow(now) |> midnight_utc()
    monday_midnight = next_monday(now) |> midnight_utc()

    {expires_time, status} =
      case params["status"] do
        "done" ->
          case frequency do
            "weekly" -> {monday_midnight, "done"}
            _ -> {midnight, "done"}
          end

        "postpone" -> {midnight, "cancelled"}
        _ -> {nil, nil}
      end

    if not is_nil(expires_time) do
      RoboticaFace.Mqtt.publish_mark(id, status, expires_time)

      conn
      |> put_flash(:info, "Mark published.")
      |> redirect(to: Routes.schedule_path(conn, :upcoming_list))
    else
      conn
      |> put_flash(:info, "Mark NOT published.")
      |> redirect(to: Routes.schedule_path(conn, :upcoming_list))
    end
  end
end

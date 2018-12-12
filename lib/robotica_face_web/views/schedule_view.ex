defmodule RoboticaFaceWeb.ScheduleView do
  use RoboticaFaceWeb, :view

  def date_time_to_local(str) do
    case Timex.parse(str, "{ISO:Extended}") do
      {:ok, dt} ->
        dt
        |> Calendar.DateTime.shift_zone!("Australia/Melbourne")
        |> Timex.format!("%F %T", :strftime)

      {:error, _} ->
        "Invalid dt"
    end
  end
end

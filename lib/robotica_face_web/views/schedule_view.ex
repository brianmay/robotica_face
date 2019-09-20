defmodule RoboticaFaceWeb.ScheduleView do
  use RoboticaFaceWeb, :view

  def date_time_to_local(dt) do
    dt
    |> Calendar.DateTime.shift_zone!("Australia/Melbourne")
    |> Timex.format!("%F %T", :strftime)
  end

  def get_action_message(action) do
    case action.message do
      nil -> nil
      message -> message.text
    end
  end
end

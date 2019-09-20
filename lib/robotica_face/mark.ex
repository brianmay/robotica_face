defmodule RoboticaFace.Mark do
  alias RoboticaFace.Date
  use EventBus.EventSource

  @spec publish_mark(String.t(), String.t(), DateTime) :: :ok | {:error, String.t()}
  def publish_mark(id, status, expires_time) do
    expires =
      expires_time
      |> Calendar.DateTime.shift_zone!("UTC")
      |> Calendar.DateTime.Format.iso8601()

    event_params = %{topic: :mark}

    EventSource.notify event_params do
      %RoboticaPlugins.Mark{
        id: id,
        status: status,
        expires_time: expires
      }
    end
  end

  def mark_task(task, status) do
    id = task.id
    frequency = task.frequency
    now = Calendar.DateTime.now_utc()
    midnight = Date.tomorrow(now) |> Date.midnight_utc()
    monday_midnight = Date.next_monday(now) |> Date.midnight_utc()

    {expires_time, status} =
      case status do
        "done" ->
          case frequency do
            "weekly" -> {monday_midnight, "done"}
            _ -> {midnight, "done"}
          end

        "postponed" ->
          {midnight, "cancelled"}

        "clear" ->
          {now, "done"}

        _ ->
          {nil, nil}
      end

    case expires_time do
      nil ->
        :error

      _ ->
        publish_mark(id, status, expires_time)
        :ok
    end
  end
end

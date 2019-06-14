defmodule RoboticaFace.Mqtt do
  alias RoboticaFace.Date

  @spec publish(String.t(), list() | map()) :: :ok | {:error, String.t()}
  defp publish(topic, data) do
    client_id = RoboticaFace.Application.get_tortoise_client_id()

    with {:ok, data} <- Jason.encode(data),
         :ok <- Tortoise.publish(client_id, topic, data, qos: 0) do
      :ok
    else
      {:error, msg} -> {:error, "Tortoise.publish got error '#{msg}'"}
    end
  end

  @spec publish_mark(String.t(), String.t(), DateTime) :: :ok | {:error, String.t()}
  def publish_mark(id, status, expires_time) do
    topic = "mark"

    expires =
      expires_time
      |> Calendar.DateTime.shift_zone!("UTC")
      |> Calendar.DateTime.Format.iso8601()

    action = %{
      id: id,
      status: status,
      expires_time: expires
    }

    publish(topic, action)
  end

  def mark_task(task, status) do
    id = task["id"]
    frequency = task["frequency"]
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

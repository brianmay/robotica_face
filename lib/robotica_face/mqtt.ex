defmodule RoboticaFace.Mqtt do
  @spec publish(String.t(), list() | map()) :: :ok | {:error, String.t()}
  defp publish(topic, data) do
    client_id = RoboticaFace.Application.get_tortoise_client_id()

    with {:ok, data} <- Poison.encode(data),
         :ok <- Tortoise.publish(client_id, topic, data, qos: 0) do
      :ok
    else
      {:error, msg} -> {:error, "Tortoise.publish got error '#{msg}'"}
    end
  end

  @spec publish_mark(String.t(), String.t(), DateTime) :: :ok | {:error, String.t()}
  def publish_mark(id, status, expires_time) do
    topic = "mark"
    expires = expires_time
              |> Calendar.DateTime.shift_zone!("UTC")
              |> Calendar.DateTime.Format.iso8601()
    action = %{
      id: id,
      status: status,
      expires_time: expires,
    }
    publish(topic, action)
  end

end

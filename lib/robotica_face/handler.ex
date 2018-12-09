defmodule RoboticaFace.Handler do
  use Tortoise.Handler
  require Logger

  def init(_args) do
    {:ok, %{}}
  end

  def connection(:up, state) do
    Logger.info("MQTT up")
    # Send request for current power level, as we have no idea.
    client_id = RoboticaFace.Application.get_tortoise_client_id()
    Tortoise.publish(client_id, "cmnd/sonoff/power", "", qos: 0)
    Tortoise.publish(client_id, "request/robotica-silverfish/schedule", "", qos: 0)
    {:ok, state}
  end

  def connection(:down, state) do
    Logger.info("MQTT down")
    {:ok, state}
  end

  def handle_message(["stat", "sonoff", "POWER"], "ON", state) do
    Logger.info("sonoff ON")
    {:ok, state}
  end

  def handle_message(["stat", "sonoff", "POWER"], "OFF", state) do
    Logger.info("sonoff OFF")
    {:ok, state}
  end

  def handle_message(["schedule", "robotica-silverfish"], schedule, state) do
    Logger.info("Got updated schedule")
    case Poison.decode(schedule) do
      {:ok, schedule} -> RoboticaFace.Schedule.set_schedule(:schedule, schedule)
      {:error, _} -> Logger.info("Invalid schedule received.")
    end
    {:ok, state}
  end

  def handle_message(_topic, _payload, state) do
    # unhandled message! You will crash if you subscribe to something
    # and you don't have a 'catch all' matcher; crashing on unexpected
    # messages could be a strategy though.
    {:ok, state}
  end

  def subscription(_status, _topic_filter, state) do
    {:ok, state}
  end

  def terminate(_reason, _state) do
    # tortoise doesn't care about what you return from terminate/2,
    # that is in alignment with other behaviours that implement a
    # terminate-callback
    :ok
  end
end

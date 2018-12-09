defmodule RoboticaFace.Sonoff do
  def turn_on() do
    client_id = RoboticaFace.Application.get_tortoise_client_id()
    Tortoise.publish(client_id, "cmnd/sonoff/power", "ON", qos: 0)
  end

  def turn_off() do
    client_id = RoboticaFace.Application.get_tortoise_client_id()
    Tortoise.publish(client_id, "cmnd/sonoff/power", "OFF", qos: 0)
  end
end

defmodule RoboticaFace.RoboticaService do
  @moduledoc false

  require Logger

  def process({:schedule = topic, id}) do
    steps = EventBus.fetch_event_data({topic, id})

    RoboticaFace.Schedule.set_schedule(:schedule, steps)

    EventBus.mark_as_completed({__MODULE__, topic, id})
  end
end

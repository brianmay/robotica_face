defmodule RoboticaFace.Schedule do
  use GenServer
  use EventBus.EventSource

  def start_link(default) do
    name = default[:name]
    GenServer.start_link(__MODULE__, nil, name: name)
  end

  def init(_) do
    event_params = %{topic: :request_schedule}

    EventSource.notify event_params do
      nil
    end

    {:ok, %{}}
  end

  def set_schedule(pid, schedule) do
    GenServer.call(pid, {:set_schedule, schedule})
  end

  def get_schedule(pid) do
    GenServer.call(pid, {:get_schedule})
  end

  def get_tasks_by_id(pid, id) do
    GenServer.call(pid, {:get_tasks_by_id, id})
  end

  def handle_call({:set_schedule, schedule}, _, state) do
    {:reply, nil, Map.put(state, :schedule, schedule)}
  end

  def handle_call({:get_schedule}, _, state) do
    {:reply, {:ok, state.schedule}, state}
  end

  def handle_call({:get_tasks_by_id, id}, _, state) do
    case Map.fetch(state, :schedule) do
      {:ok, schedule} ->
        tasks =
          schedule
          |> Enum.map(fn step ->
            tasks = Enum.filter(step.tasks, fn task -> task.id == id end)
            %{step | tasks: tasks}
          end)
          |> Enum.filter(fn step -> length(step.tasks) > 0 end)

        {:reply, {:ok, tasks}, state}

      :error ->
        {:reply, :error, state}
    end
  end
end

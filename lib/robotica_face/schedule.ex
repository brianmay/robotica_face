defmodule RoboticaFace.Schedule do
  use GenServer

  def start_link(default) do
    name = default[:name]
    GenServer.start_link(__MODULE__, nil, name: name)
  end

  def init(_) do
    {:ok, %{}}
  end

  def set_schedule(pid, hostname, schedule) do
    GenServer.call(pid, {:set_schedule, hostname, schedule})
  end

  def get_host_list(pid) do
    GenServer.call(pid, {:get_host_list})
  end

  def get_schedule(pid, hostname) do
    GenServer.call(pid, {:get_schedule, hostname})
  end

  def get_tasks_by_id(pid, hostname, id) do
    GenServer.call(pid, {:get_tasks_by_id, hostname, id})
  end

  def handle_call({:set_schedule, hostname, schedule}, _, state) do
    {:reply, nil, Map.put(state, hostname, schedule)}
  end

  def handle_call({:get_host_list}, _, state) do
    {:reply, Map.keys(state), state}
  end

  def handle_call({:get_schedule, hostname}, _, state) do
    {:reply, Map.fetch(state, hostname), state}
  end

  def handle_call({:get_tasks_by_id, hostname, id}, _, state) do
    case Map.fetch(state, hostname) do
      {:ok, schedule} ->
        tasks =
          schedule
          |> Enum.map(fn step ->
            tasks = Enum.filter(step["tasks"], fn task -> task["id"] == id end)
            %{step | "tasks" => tasks}
          end)
          |> Enum.filter(fn step -> length(step["tasks"]) > 0 end)

        {:reply, {:ok, tasks}, state}

      :error ->
        {:reply, :error, state}
    end
  end
end

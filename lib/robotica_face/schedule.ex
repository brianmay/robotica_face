defmodule RoboticaFace.Schedule do
  use GenServer

  def start_link(default) do
    name = default[:name]
    GenServer.start_link(__MODULE__, nil, name: name)
  end

  def init(_) do
    {:ok, []}
  end

  def set_schedule(pid, schedule) do
    GenServer.call(pid, {:set, schedule})
  end

  def get_schedule(pid) do
    GenServer.call(pid, {:get})
  end

  def handle_call({:set, schedule}, _, _state) do
    {:reply, nil, schedule}
  end

  def handle_call({:get}, _, state) do
    {:reply, state, state}
  end
end

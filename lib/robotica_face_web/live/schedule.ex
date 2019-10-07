defmodule RoboticaFaceWeb.Live.Schedule do
  use Phoenix.LiveView

  def render(assigns) do
    ~L"""
    <table>
      <thead>
        <tr>
          <th>Time</th>
          <th>Locations</th>
          <th>Message</th>
          <th>Marks</th>
          <th>Actions</th>
        </th>
      </thead>
      <tbody>
        <%= for step <- @schedule do %>
          <%= for task <- step.tasks do %>
            <tr>
              <td><%= date_time_to_local(step.required_time) %></td>
              <td><%= Enum.join(task.locations, ", ") %></td>
              <td><%= get_action_message(task.action) %></td>
              <td><%= task.mark %></td>
              <td>
                <button phx-click="mark" phx-value-mark="done" phx-value-task_id="<%= task.id %>">Done</button>
                <button phx-click="mark" phx-value-mark="postponed" phx-value-task_id="<%= task.id %>">Postpone</button>
                <button phx-click="mark" phx-value-mark="clear" phx-value-task_id="<%= task.id %>">Clear</button>
              </td>
            </tr>
          <% end %>
        <% end %>
       </tbody>
    </table>
    """
  end

  def mount(_, socket) do
    RoboticaFace.Schedule.register(self())
    schedule = get_schedule()
    {:ok, assign(socket, :schedule, schedule)}
  end

  def handle_cast({:schedule, schedule}, socket) do
    {:noreply, assign(socket, :schedule, schedule)}
  end

  defp date_time_to_local(dt) do
    dt
    |> Calendar.DateTime.shift_zone!("Australia/Melbourne")
    |> Timex.format!("%F %T", :strftime)
  end

  defp get_schedule() do
    case RoboticaFace.Schedule.get_schedule() do
      {:ok, schedule} -> schedule
      :error -> []
    end
  end

  defp get_action_message(action) do
    case action.message do
      nil -> nil
      message -> message.text
    end
  end

  defp get_task(task_id) do
    steps = RoboticaFace.Schedule.get_tasks_by_id(task_id)

    case steps do
      {:ok, [head | _]} -> hd(head.tasks)
      {:ok, _} -> nil
      :error -> :error
    end
  end

  defp do_mark(task, status) do
    result = RoboticaFace.Mark.mark_task(task, status)

    case result do
      :ok -> nil
      :error -> nil
    end
  end

  def handle_event("mark", %{"mark" => status, "task_id" => id}, socket) do
    case get_task(id) do
      nil -> nil
      task -> do_mark(task, status)
    end

    {:noreply, socket}
  end
end

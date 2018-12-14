defmodule RoboticaFaceWeb.ApiController do
  use RoboticaFaceWeb, :controller

  defp delta_to_string(scheduled, now) do
    {:ok, seconds, _microseconds, _} = Calendar.DateTime.diff(scheduled, now)

    hours = div(seconds, 3600)
    seconds = rem(seconds, 3600)

    minutes = div(seconds, 60)
    seconds = rem(seconds, 60)

    cond do
      hours > 1 -> "#{hours} hours, #{minutes} minutes"
      hours == 1 -> "1 hour, #{minutes} minutes"
      minutes > 1 -> "#{minutes} minutes"
      minutes == 1 -> "1 minute"
      seconds == 1 -> "1 second"
      true -> "#{seconds} seconds"
    end
  end

  defp parse_steps(steps) do
    steps
    |> Enum.map(fn step ->
      time = Timex.parse!(step["required_time"], "{ISO:Extended}")
      %{step | "required_time" => time}
    end)
  end

  defp count_tasks(steps) do
    Enum.reduce(steps, 0, fn step, acc -> acc + length(step["tasks"]) end)
  end

  defp filter_steps(steps, filter_task?) do
    steps
    |> Enum.map(fn step ->
      tasks = Enum.filter(step["tasks"], filter_task?)
      %{step | "tasks" => tasks}
    end)
    |> Enum.filter(fn step ->
      length(step["tasks"]) > 0
    end)
  end

  defp filter_steps_before_time(steps, threshold) do
    steps
    |> Enum.filter(fn step ->
      Calendar.DateTime.before?(step["required_time"], threshold)
    end)
  end

  defp filter_todo_task?(task) do
    case task["mark"] do
      "done" -> false
      "cancelled" -> false
      _ -> true
    end
  end

  defp filter_query_task?(task, query) do
    msg = get_in(task, ["action", "message", "text"])

    Enum.all?(String.split(query), fn word ->
      case msg do
        nil -> false
        msg -> msg =~ word
      end
    end)
  end

  defp steps_to_message(steps, now) do
    messages =
      steps
      |> Enum.map(fn step ->
        time = step["required_time"]

        msgs =
          Enum.map(step["tasks"], fn task ->
            get_in(task, ["action", "message", "text"])
          end)
          |> Enum.filter(fn msg -> not is_nil(msg) end)

        {time, msgs}
      end)
      |> Enum.filter(fn {_, msgs} -> length(msgs) > 0 end)

    case messages do
      [] ->
        nil

      list ->
        Enum.map(list, fn {time, msgs} ->
          time_str = delta_to_string(time, now)
          msg_str = Enum.join(msgs, " and ")
          "In #{time_str}, #{msg_str}"
        end)
        |> Enum.join(" ")
    end
  end

  def index(conn, params) do
    IO.inspect(params)
    query = Map.get(params, "queryResult", %{})
    parameters = Map.get(query, "parameters", %{})
    intent = get_in(query, ["intent", "name"])
    token = get_in(params, ["originalDetectIntentRequest", "payload", "user", "idToken"])

    result =
      case token do
        nil -> {:error, "No token"}
        _ -> Joken.verify(token, Joken.Signer.parse_config(:rs256))
      end

    known_user =
      case result do
        {:ok, claims} ->
          case {claims["email"], claims["email_verified"]} do
            {"brian@linuxpenguins.xyz", true} -> true
            _ -> false
          end

        {:error, _} ->
          false
      end

    assigns =
      cond do
        not known_user ->
          %{
            fulfillmentText:
              "I am so sorry. I do not know you. Tux says never to talk to strange penguins. Go away."
          }

        true ->
          process_intent(intent, parameters)
      end

    render(conn, "index.json", assigns)
  end

  defp process_intent(intent, parameters) do
    case intent do
      "projects/robotica-3746c/agent/intents/97e7f7df-4e1a-4bbe-8308-7e9a86789c69" ->
        cond do
          parameters["lunch"] not in ["Yes", ""] ->
            %{
              fulfillmentText: "I am so sorry. The Kids must make lunch before turning on the TV."
            }

          parameters["teeth"] not in ["Yes", ""] ->
            %{
              fulfillmentText:
                "I am so sorry. The Kids must clean teeth before turning on the TV."
            }

          parameters["bed"] not in ["No", ""] ->
            %{
              fulfillmentText:
                "I am so sorry. The Kids will wake up the dog who will watch TV all night if you turn it on now."
            }

          true ->
            RoboticaFace.Sonoff.turn_on()

            %{
              fulfillmentText: "Turning TV on."
            }
        end

      "projects/robotica-3746c/agent/intents/c2b9befe-126f-4452-bc18-018f126f6beb" ->
        {:ok, steps} = RoboticaFace.Schedule.get_schedule(:schedule, "robotica-silverfish")
        now = Calendar.DateTime.now_utc()

        messages =
          steps
          |> parse_steps()
          |> filter_steps(&filter_todo_task?/1)
          |> Enum.take(3)
          |> steps_to_message(now)

        %{
          fulfillmentText: messages || "There are no tasks"
        }

      "projects/robotica-3746c/agent/intents/8059af23-6a9f-46a4-ab7f-7ea713a86d79" ->
        query = parameters["query"]
        {:ok, steps} = RoboticaFace.Schedule.get_schedule(:schedule, "robotica-silverfish")
        now = Calendar.DateTime.now_utc()

        midnight =
          RoboticaFace.Date.tomorrow(now)
          |> RoboticaFace.Date.midnight_utc()

        steps =
          steps
          |> parse_steps()
          |> filter_steps_before_time(midnight)
          |> filter_steps(fn task -> filter_query_task?(task, query) end)

        message = steps_to_message(steps, now)
        count = count_tasks(steps)

        %{
          fulfillmentText: "There were #{count} tasks. #{message}"
        }

      _ ->
        %{
          fulfillmentText: "Something went wrong! I am very sorry."
        }
    end
  end
end

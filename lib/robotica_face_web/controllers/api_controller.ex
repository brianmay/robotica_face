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

  defp expand_schedule(steps) do
    steps
    |> Enum.reduce([], fn step, acc ->
      time = Timex.parse!(step["required_time"], "{ISO:Extended}")

      Enum.reduce(step["tasks"], acc, fn task, task_acc ->
        [{time, task} | task_acc]
      end)
    end)
    |> Enum.reverse()
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
      case intent do
        "projects/robotica-3746c/agent/intents/97e7f7df-4e1a-4bbe-8308-7e9a86789c69" ->
          cond do
            not known_user ->
              %{
                fulfillmentText:
                  "I am so sorry. I do not know you. Tux says never to talk to strange penguins. Go away."
              }

            parameters["lunch"] not in ["Yes", ""] ->
              %{
                fulfillmentText:
                  "I am so sorry. The Kids must make lunch before turning on the TV."
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
          esteps = expand_schedule(steps)
          now = Calendar.DateTime.now_utc()

          messages =
            esteps
            |> Enum.filter(fn {_, task} ->
              case task["mark"] do
                "done" -> false
                "cancelled" -> false
                _ -> true
              end
            end)
            |> Enum.map(fn {time, task} -> {time, get_in(task, ["action", "message", "text"])} end)
            |> Enum.filter(fn {_, msg} -> not is_nil(msg) end)
            |> Enum.map(fn {time, msg} ->
              time_str = delta_to_string(time, now)
              "In #{time_str}, #{msg}"
            end)
            |> Enum.take(5)
            |> Enum.join(" ")

          %{
            fulfillmentText: messages
          }

        "projects/robotica-3746c/agent/intents/8059af23-6a9f-46a4-ab7f-7ea713a86d79" ->
          parameters = Map.get(query, "parameters", %{})
          query = parameters["query"]
          {:ok, steps} = RoboticaFace.Schedule.get_schedule(:schedule, "robotica-silverfish")
          esteps = expand_schedule(steps)
          now = Calendar.DateTime.now_utc()
          midnight = RoboticaFace.Date.tomorrow(now) |> RoboticaFace.Date.midnight_utc()

          messages =
            esteps
            |> Enum.filter(fn {time, _} -> Calendar.DateTime.before?(time, midnight) end)
            |> Enum.map(fn {time, task} -> {time, get_in(task, ["action", "message", "text"])} end)
            |> Enum.filter(fn {_, msg} -> not is_nil(msg) end)
            |> Enum.filter(fn {_, msg} ->
              Enum.all?(String.split(query), fn word -> msg =~ word end)
            end)
            |> Enum.map(fn {time, msg} ->
              time_str = delta_to_string(time, now)
              "In #{time_str}, #{msg}"
            end)

          joined_messages = Enum.join(messages, " ")

          %{
            fulfillmentText: "There were #{length(messages)} results. #{joined_messages}"
          }

        _ ->
          %{
            fulfillmentText: "Something went wrong! I am very sorry."
          }
      end

    render(conn, "index.json", assigns)
  end
end

defmodule RoboticaFaceWeb.ApiController do
  use RoboticaFaceWeb, :controller

  defp delta_to_string(scheduled, now) do
    {:ok, seconds, _microseconds, _} = Calendar.DateTime.diff(scheduled, now)

    IO.puts(seconds)

    hours = div(seconds, 3600)
    seconds = rem(seconds, 3600)

    minutes = div(seconds, 60)
    seconds = rem(seconds, 60)

    cond do
      hours > 0 -> "#{hours} hours, #{minutes} minutes and #{seconds} seconds"
      minutes > 0 -> "#{minutes} minutes and #{seconds} seconds"
      true -> "#{seconds} seconds"
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
          steps = RoboticaFace.Schedule.get_schedule(:schedule)
          now = Calendar.DateTime.now_utc()

          messages =
            case steps do
              [head | _] ->
                head["tasks"]
                |> Enum.map(fn task ->
                  time = Timex.parse!(head["required_time"], "{ISO:Extended}")
                  time_str = delta_to_string(time, now)
                  msg = get_in(task, ["action", "message", "text"])
                  "In #{time_str} #{msg}"
                end)

              _ ->
                ["There are no tasks"]
            end

          %{
            fulfillmentText: Enum.join(messages, ", ")
          }

        _ ->
          %{
            fulfillmentText: "Something went wrong! I am very sorry."
          }
      end

    render(conn, "index.json", assigns)
  end
end

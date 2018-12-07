defmodule RoboticaFaceWeb.ApiController do
  use RoboticaFaceWeb, :controller

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

    case intent do
      "projects/robotica-3746c/agent/intents/97e7f7df-4e1a-4bbe-8308-7e9a86789c69" ->
        assigns =
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
              %{
                fulfillmentText: "Thank you for your request. Please turn on the TV yourself."
              }
          end

        render(conn, "index.json", assigns)

      _ ->
        render(conn, "index.json", %{
          fulfillmentText: "Something went wrong! I am very sorry."
        })
    end
  end
end

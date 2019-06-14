defmodule RoboticaFace.Auth.Guardian do
  @moduledoc false

  use Guardian, otp_app: :robotica_face

  alias RoboticaFace.Accounts

  def subject_for_token(user, _claims) do
    sub = to_string(user.id)
    {:ok, sub}
  end

  def resource_from_claims(%{"sub" => id}) do
    user = Accounts.get_user!(id)
    {:ok, user}
  end
end

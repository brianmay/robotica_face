defmodule RoboticaFace.Auth do
  require Ecto.Query

  alias Comeonin.Bcrypt

  alias RoboticaFace.Accounts.User
  alias RoboticaFace.Auth.Guardian
  alias RoboticaFace.Repo

  def authenticate_user(email, given_password) do
    query = Ecto.Query.from(u in User, where: u.email == ^email)

    Repo.one(query)
    |> check_password(given_password)
  end

  defp check_password(nil, _), do: {:error, "Incorrect username or password"}

  defp check_password(user, given_password) do
    case Bcrypt.checkpw(given_password, user.password_hash) do
      true -> {:ok, user}
      false -> {:error, "Incorrect username or password"}
    end
  end

  def login(conn, user) do
    conn
    |> Guardian.Plug.sign_in(user)
    |> Plug.Conn.assign(:current_user, user)
  end

  def logout(conn) do
    conn
    |> Guardian.Plug.sign_out()
  end

  def current_user(conn) do
    Guardian.Plug.current_resource(conn)
  end

  def user_signed_in?(conn) do
    !!current_user(conn)
  end
end

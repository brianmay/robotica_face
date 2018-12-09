# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     RoboticaFace.Repo.insert!(%RoboticaFace.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.
alias RoboticaFace.Repo
alias RoboticaFace.Accounts.User

admin_params = %{
  name: "Admin User",
  email: "admin@test.com",
  password: "supersecret",
  is_admin: true
}

unless Repo.get_by(User, email: admin_params[:email]) do
  %User{}
  |> User.changeset(admin_params)
  |> Repo.insert!()
end

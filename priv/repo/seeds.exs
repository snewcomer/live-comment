# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     LiveComment.Repo.insert!(%LiveComment.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.
#
alias LiveComment.{Repo, Managed}

comments = [
  %{
    body: "Tweedle Dee"
  },
  %{
    body: "Dum"
  }
]

case Repo.all(Managed.Comment) do
  [] ->
    comments
    |> Enum.each(fn comment ->
      Managed.create_comment(comment)
    end)
  _ ->
    IO.puts("Already have some comments")
end

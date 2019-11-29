defmodule LiveComment.CommentLiveTest do
  use LiveCommentWeb.ConnCase, async: false
  import Phoenix.LiveViewTest

  alias LiveComment.Managed
  alias LiveComment.Managed.Comment
  alias LiveComment.Repo

  @valid_attrs %{body: "some body"}

  def comment_fixture(attrs \\ %{}) do
    {:ok, comment} =
      attrs
      |> Enum.into(@valid_attrs)
      |> Managed.create_comment()

    comment
  end

  describe "comments" do
    test "index", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/")
      assert html =~ "<button type=\"submit\">Comment</button>"
    end

    test "index renders with comments", %{conn: conn} do
      comment_fixture()
      comment_fixture(%{body: "other body"})
      {:ok, _view, html} = live(conn, "/")
      assert html =~ "some body"
      assert html =~ "other body"
    end

    @tag :skip
    test "can submit main comment", %{conn: conn} do
      comment_fixture()
      {:ok, view, html} = live(conn, "/")
      # this will call async send_update/2
      # Floki.find(id) is called before `Show` receives the message from send_update/2
      assert render_submit(view, :save, %{"comment" => %{"body" => "weedledoop"}}) =~ "weedledoop"
    end

    @tag :skip
    test "can add new comment", %{conn: conn} do
      comment = comment_fixture()
      {:ok, view, _html} = live(conn, "/")
      assert render(view) =~ "some body"

      {:ok, comment_2} = Repo.insert(Comment.changeset(%Comment{}, %{body: "foobar", parent_id: comment.id}))
      send(view.pid, {Managed, :new_comment, comment_2}) # async send_update/2 LiveView Component called

      Process.sleep(1000)

      assert render(view) =~ "some body"
      assert render(view) =~ "foobar"
    end
  end
end


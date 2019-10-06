defmodule LiveCommentWeb.CommentLive do
  use Phoenix.LiveView

  alias LiveComment.Managed
  alias LiveComment.Managed.Comment

  def render(assigns) do
    Phoenix.View.render(LiveCommentWeb.CommentView, "main.html", assigns)
  end

  def mount(_session, socket) do
    with comments <- Managed.list_comments(),
      comments = Managed.nested_comments(comments),
      changeset = Managed.change_comment()
    do
      socket = assign(socket, [changeset: changeset, comments: comments])
      {:ok, socket}
    end
  end

  def handle_event("save", %{"comment" => comment_params} = _params, socket) do
    case Managed.create_comment(comment_params) do
      {:ok, _comment} ->
        with comments <- Managed.list_comments(),
          comments = Managed.nested_comments(comments)
        do
          # We need to return out all comments with parent-child relationships on update.
          # Otherwise, we aren't sure exactly where a new comment should end up.
          # This has slight performance implications
          {:noreply, assign(socket, comments: comments)}
        end
      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end


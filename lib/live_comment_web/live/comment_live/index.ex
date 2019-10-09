defmodule LiveCommentWeb.CommentLive.Index do
  use Phoenix.LiveView
  use Phoenix.HTML

  alias LiveComment.Managed
  alias LiveCommentWeb.CommentLive

  def render(assigns) do
    ~L"""
    <div class="main">
      <div>
        <%= f = form_for @changeset, "#", [id: "main-comment-form", class: "comment_form", phx_submit: :save] %>
          <%= textarea f, :body, rows: 2, required: true, placeholder: "Cool beans..." %>
          <div class="comment_form-footer">
            <button type="submit">Comment</button>
          </div>
        </form>
      </div>

      <div class="comment_list">
        <%= for comment <- @comments do %>
          <%= live_component @socket, CommentLive.Show, id: comment.id, comment: comment, kind: :parent %>
        <% end %>
      </div>
    </div>
    """
  end

  def mount(_session, socket) do
    with comments <- Managed.list_comments(),
      comments = Managed.nested_comments(comments),
      changeset = Managed.change_comment()
    do
      socket = assign(socket, [changeset: changeset, comments: comments])
      {:ok, socket, temporary_assigns: [comments: []]}
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


defmodule LiveCommentWeb.CommentLive.Index do
  use Phoenix.LiveView
  use Phoenix.HTML

  alias LiveComment.Managed
  alias LiveCommentWeb.CommentLive

  def render(assigns) do
    ~L"""
    <div class="main">
      <div>
        <%= f = form_for @changeset, "#", class: "comment_form", phx_submit: "save" %>
          <%= textarea f, :body, rows: 2, required: true,
            placeholder: "Cool beans...",
            phx_hook: "CommentTextArea" %>
          <div class="comment_form-footer">
            <button type="submit">Comment</button>
          </div>
        </form>
      </div>

      <div class="comment_list" id="root-comments" phx-update="append">
        <%= for comment <- @comments do %>
          <%= live_component @socket, CommentLive.Show, id: comment.id, comment: comment, kind: :parent %>
        <% end %>
      </div>
    </div>
    """
  end

  def mount(_session, socket) do
    comments = Managed.list_root_comments()
    changeset = Managed.change_comment()
    socket = assign(socket, [changeset: changeset, comments: comments])
    if connected?(socket), do: Managed.subscribe("lobby")

    {:ok, socket, temporary_assigns: [comments: []]}
  end

  def handle_event("save", %{"comment" => comment_params}, socket) do
    case Managed.create_comment(comment_params) do
      {:ok, comment} ->
        {:noreply, assign(socket, comments: [comment], changeset: Managed.change_comment())}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  def handle_info({Managed, :new_comment, comment}, socket) do
    if comment.parent_id do
      send_update(CommentLive.Show, comment.parent_id, %{children: [comment]})
      {:noreply, socket}
    else
      {:noreply, assign(socket, comments: [comment])}
    end
  end
end


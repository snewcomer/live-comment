defmodule LiveCommentWeb.CommentLive.Show do
  use Phoenix.LiveComponent
  use Phoenix.HTML

  alias LiveComment.Managed
  alias LiveComment.Managed.Comment
  alias LiveCommentWeb.CommentLive

  def render(assigns) do
    ~L"""
    <a id="comment-anchor-<%= @comment.id %>" class="anchor"></a>
    <article class="comment comment--<%= @kind %>" id="comment-<%= @comment.id %>">
      <div class="comment-body">
        (<%= @id %>) <%= @comment.body %>
      </div>

      <div class="comment-footer">
        <p class="comment-reply">
          <a href="#" phx-click="toggle-reply" title="Reply to this comment">reply</a>
        </p>

        <p class="comment-permalink">
          <%= link @comment.inserted_at, to: "#comment#{@id}" %>
        </p>
      </div>

      <%= if @form_visible do %>
        <%= f = form_for @changeset, "#", [class: "comment_form", phx_submit: :save] %>
          <%= textarea f, :body, rows: 2, required: true, placeholder: "Your reply..." %>
          <div class="comment_form-footer">
            <button type="submit">Reply</button>
          </div>
        </form>
      <% end %>

      <section class="comment-replies" id="replies-<%= @comment.id %>" phx-update="append">
        <% IO.inspect({:render_children, connected?(@socket), @id, for(c <- @children, do: "#{c.id}")}) %>
        <%= for child <- @children do %>
          <%= live_component @socket, CommentLive.Show, id: child.id, comment: child, kind: :child %>
        <% end %>
      </section>
    </article>
    """
  end

  def mount(socket) do
    {:ok, assign(socket, form_visible: false, changeset: Managed.change_comment()),
     temporary_assigns: [comment: nil, children: []]}
  end

  def update(assigns, socket) do
    # IO.puts("  " <> inspect({:update, assigns.comment.body}))
    {:ok, assign(socket, Map.put(assigns, :children, assigns.comment.children))}
  end

  def handle_event("toggle-reply", _, socket) do
    {:noreply, update(socket, :form_visible, &(!&1))}
  end

  def handle_event("save", %{"comment" => comment_params}, socket) do
    comment_params
    |> Map.put("parent_id", socket.assigns.id)
    |> Managed.create_comment()
    |> case do
      {:ok, new_comment} ->
        {:noreply, assign(socket, :children, [new_comment])}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end

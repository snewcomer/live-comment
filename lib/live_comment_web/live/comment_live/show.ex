defmodule LiveCommentWeb.CommentLive.Show do
  use Phoenix.LiveComponent
  use Phoenix.HTML

  alias LiveComment.Managed
  alias LiveCommentWeb.CommentLive
  alias LiveCommentWeb.CommentView

  def render(assigns) do
    ~L"""
    <article class="comment comment--<%= @kind %>" id="comment-<%= @id %>">
      <div class="comment-body">
        <%= @comment.body %>
      </div>

      <div class="comment-footer">
        <p class="comment-reply">
          <a href="javascript:;" phx-click="toggle-reply" phx-target="#comment-<%= @id %>" title="Reply to this comment">reply</a>
        </p>

        <p class="comment-permalink">
          <%= link CommentView.format_time(@comment.inserted_at), to: "#comment#{@id}" %>
        </p>
      </div>

      <%= if @form_visible do %>
        <%= f = form_for @changeset, "#",
          [
            class: "comment_form",
            phx_submit: :save,
            phx_target: "#comment-#{@id}",
            phx_hook: "Comment"
          ] %>
          <%= textarea f, :body, rows: 2, required: true,
            placeholder: "Your reply..." %>
          <div class="comment_form-footer">
            <button type="submit">Reply</button>
          </div>
        </form>
      <% end %>

      <section class="comment-replies" phx-update="append" id="replies-<%= @id %>">
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

  def preload(list_of_assigns) do
    # https://hexdocs.pm/phoenix_live_view/Phoenix.LiveComponent.html#module-preloading-and-update
    parent_ids = Enum.map(list_of_assigns, & &1.id)
    children = Managed.fetch_child_comments(parent_ids)

    Enum.map(list_of_assigns, fn assigns ->
      Map.put(assigns, :children, Map.get(children, assigns.id, []))
    end)
  end

  def handle_event("toggle-reply", _, socket) do
    {:noreply, update(socket, :form_visible, &(!&1))}
  end

  def handle_event("save", %{"comment" => comment_params}, socket) do
    IO.inspect comment_params
    comment_params
    |> Map.put("parent_id", socket.assigns.id)
    |> Managed.create_comment()
    |> case do
      {:ok, new_comment} ->
        {:noreply, assign(socket, form_visible: false, children: [new_comment])}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end

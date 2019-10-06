defmodule LiveCommentWeb.PageController do
  use LiveCommentWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end

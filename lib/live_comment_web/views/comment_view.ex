defmodule LiveCommentWeb.CommentView do
  use LiveCommentWeb, :view

  alias LiveComment.Managed.Comment

  def format_time(naive) do
    Comment.human_date(naive)
  end
end

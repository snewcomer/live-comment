defmodule LiveComment.Managed do
  @moduledoc """
  Managed the comments
  """

  import Ecto.Query, warn: false
  alias LiveComment.Repo

  alias LiveComment.Managed.Comment

  @pubsub LiveComment.PubSub
  @topic "comments"

  def subscribe(content_id) do
    Phoenix.PubSub.subscribe(@pubsub, topic(content_id))
  end

  defp topic(content_id), do: "#{@topic}:#{content_id}"

  @doc """
  Returns the list of root comments.

  ## Examples

      iex> list_root_comments()
      [%Comment{}, ...]

  """
  def list_root_comments do
    from(c in Comment, where: is_nil(c.parent_id), order_by: [asc: :inserted_at])
    |> Repo.all()
  end

  @doc """
  Creates a comment.

  ## Examples

      iex> create_comment(%{field: value})
      {:ok, %Comment{}}

      iex> create_comment(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_comment(attrs \\ %{}) do
    %Comment{}
    |> Comment.changeset(attrs)
    |> Repo.insert()
    |> preload()
    |> broadcast_new_comment()
  end
  defp preload({:ok, %Comment{} = comment}), do: {:ok, Repo.preload(comment, :children)}
  defp preload({:error, _reason} = err), do: err

  defp broadcast_new_comment({:ok, comment}) do
    Phoenix.PubSub.broadcast_from!(@pubsub, self(), topic("lobby"), {__MODULE__, :new_comment, comment})
    {:ok, comment}
  end
  defp broadcast_new_comment({:error, _} = err), do: err

  @doc """
  Fetches all child comments for a list of parent comment IDs.

  Returns results as a map grouped by parent_id.
  """
  def fetch_child_comments(parent_ids) do
    from(c in Comment, where: c.parent_id in ^parent_ids)
    |> Repo.all()
    |> Enum.group_by(&(&1.parent_id))
  end

  @doc """
  ## Examples

      iex> nested_comments(comment)
      {:ok, %Comment{}}

      iex> nested_comments(comment)
      {:error, %Ecto.Changeset{}}

  """
  def nested_comments(comments) do
    Comment.nested(comments)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking comment changes.

  ## Examples

      iex> change_comment(comment)
      %Ecto.Changeset{source: %Comment{}}

  """
  def change_comment(comment \\ %Comment{}) do
    Comment.changeset(comment, %{})
  end
end

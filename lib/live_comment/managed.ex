defmodule LiveComment.Managed do
  @moduledoc """
  Managed the comments
  """

  import Ecto.Query, warn: false
  alias LiveComment.Repo

  alias LiveComment.Managed.Comment

  @doc """
  Returns the list of comments.

  ## Examples

      iex> list_comments()
      [%Comment{}, ...]

  """
  def list_comments do
    Comment
    |> Comment.newest_last()
    |> Comment.preload_all()
    |> Repo.all()
  end

  @doc """
  Gets a single comment.

  Raises `Ecto.NoResultsError` if the Comment does not exist.

  ## Examples

      iex> get_comment!(123)
      %Comment{}

      iex> get_comment!(456)
      ** (Ecto.NoResultsError)

  """
  def get_comment!(id), do: Repo.get!(Comment, id)

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
  end
  defp preload({:ok, %Comment{} = comment}), do: {:ok, Repo.preload(comment, :children)}
  defp preload({:error, _reason} = err), do: err

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

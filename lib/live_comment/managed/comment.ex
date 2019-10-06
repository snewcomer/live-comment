defmodule LiveComment.Managed.Comment do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query, only: [from: 2]

  alias LiveComment.Repo

  schema "comments" do
    field :body, :string

    belongs_to :parent, __MODULE__, foreign_key: :parent_id
    has_many :children, __MODULE__, foreign_key: :parent_id

    timestamps()
  end

  @doc false
  def changeset(comment, attrs) do
    comment
    |> cast(attrs, [:body, :parent_id])
    |> validate_required([:body])
  end

  def nested(nil), do: []
  def nested([]), do: []
  def nested(comments) do
    comments
    |> Enum.map(&Map.put(&1, :children, []))
    |> Enum.reduce(%{}, fn comment, map ->
      comment = %{comment | children: Map.get(map, comment.id, [])}
      Map.update(map, comment.parent_id, [comment], fn comments -> [comment | comments] end)
    end)
    |> Map.get(nil)
  end

  def preload_all(query = %Ecto.Query{}) do
    query
    |> Ecto.Query.preload(:parent)
    |> Ecto.Query.preload(:children)
  end
  def preload_all(comment) do
    comment
    |> Repo.preload(:parent)
    |> Repo.preload(:children)
  end

  def newest_last(query, field \\ :inserted_at) do
    from(q in query, order_by: [desc: ^field])
  end

  def human_date(naive) do
    [naive.year, naive.month, naive.day]
    |> Enum.join("/")
  end
end

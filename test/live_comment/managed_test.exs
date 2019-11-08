defmodule LiveComment.ManagedTest do
  use LiveComment.DataCase

  alias LiveComment.Managed

  describe "comments" do
    alias LiveComment.Managed.Comment

    @valid_attrs %{body: "some body"}
    @invalid_attrs %{body: nil}

    def comment_fixture(attrs \\ %{}) do
      {:ok, comment} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Managed.create_comment()

      comment
    end

    test "list_root_comments/0 returns all non parent_id comments" do
      comment = comment_fixture()
      comment_fixture(%{parent_id: comment.id})
      assert length(Managed.list_root_comments()) == 1
    end

    test "fetch_child_comments/1 returns all non parent_id comments" do
      comment = comment_fixture()
      parent_id = comment.id
      comment2 = comment_fixture(%{parent_id: comment.id})
      child_id = comment2.id
      assert %{^parent_id => [%Comment{id: ^child_id}]} = Managed.fetch_child_comments([parent_id])
    end

    test "create_comment/1 with valid data creates a comment" do
      assert {:ok, %Comment{} = comment} = Managed.create_comment(@valid_attrs)
      assert comment.body == "some body"
    end

    test "create_comment/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Managed.create_comment(@invalid_attrs)
    end

    test "change_comment/1 returns a comment changeset" do
      comment = comment_fixture()
      assert %Ecto.Changeset{} = Managed.change_comment(comment)
    end

    test "nested_comments/1" do
      parent = %{id: 1, body: "my comment", parent_id: nil}
      reply = %{id: 2, body: "my reply", parent_id: 1}

      nested = Managed.nested_comments([reply, parent])

      assert length(nested) == 1
      assert length(List.first(nested).children) == 1
    end
  end
end

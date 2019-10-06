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

    test "list_comments/0 returns all comments" do
      comment = comment_fixture()
      assert Managed.list_comments() |> Enum.at(0) |> Map.get(:id) == comment.id
    end

    test "get_comment!/1 returns the comment with given id" do
      comment = comment_fixture()
      assert Managed.get_comment!(comment.id) == comment
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

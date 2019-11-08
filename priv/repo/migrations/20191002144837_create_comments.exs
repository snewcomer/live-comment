defmodule LiveComment.Repo.Migrations.CreateComments do
  use Ecto.Migration

  def change do
    create table(:comments) do
      add :body, :text

      add :parent_id, references(:comments)

      timestamps()
    end

  end
end

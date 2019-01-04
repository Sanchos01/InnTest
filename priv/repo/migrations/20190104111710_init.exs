defmodule InnTest.Repo.Migrations.Init do
  use Ecto.Migration

  def change do
    create table(:inns) do
      add :inn, :string
      add :valid, :boolean

      timestamps(
        updated_at: false
      )
    end
  end
end

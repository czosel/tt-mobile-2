defmodule TtMobile.Repo.Migrations.AddClubTable do
  use Ecto.Migration

  def change do
    create table(:club) do
      add :name, :string
    end
  end
end

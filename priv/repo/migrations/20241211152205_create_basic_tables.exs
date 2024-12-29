defmodule TtMobile.Repo.Migrations.CreateBasicTables do
  use Ecto.Migration

  def change do
    create table(:association) do
      add :name, :string
      add :code, :string
    end

    create unique_index(:association, [:code])

    create table(:league, primary_key: false) do
      add :id, :integer, primary_key: true
      add :name, :string
      add :association_id, references(:association)
    end

    create table(:club) do
      add :name, :string
    end
  end
end

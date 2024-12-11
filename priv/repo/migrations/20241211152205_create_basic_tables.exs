defmodule TtMobile.Repo.Migrations.CreateBasicTables do
  use Ecto.Migration

  def change do
    create table(:association) do
      add :name, :string
    end

    create table(:league) do
      add :name, :string
      add :association_id, references(:association)
    end
  end
end

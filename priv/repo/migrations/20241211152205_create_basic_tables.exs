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

    create table(:club, primary_key: false) do
      add :id, :integer, primary_key: true
      add :name, :string
    end

    create table(:team, primary_key: false) do
      add :id, :integer, primary_key: true
      add :name, :string
      add :club_id, references(:club)
      add :league_id, references(:league)
    end

    create table(:game) do
      add :code, :string
      add :start, :naive_datetime
      add :home_team_id, references(:team)
      add :guest_team_id, references(:team)
      add :result, :string
    end

    create unique_index(:game, [:code])
    create unique_index(:game, [:start, :home_team_id, :guest_team_id], name: :unique_game)
  end
end

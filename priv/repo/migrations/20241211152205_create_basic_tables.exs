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
      add :game_count, :integer
      add :win_count, :integer
      add :draw_count, :integer
      add :lose_count, :integer
      add :games_won, :integer
      add :games_lost, :integer
      add :points_won, :integer
      add :points_lost, :integer
    end

    create table(:game) do
      add :code, :string
      add :start, :naive_datetime
      add :league_id, references(:league)
      add :home_team_id, references(:team)
      add :guest_team_id, references(:team)
      add :result, :string
    end

    create unique_index(:game, [:code])
    create unique_index(:game, [:start, :home_team_id, :guest_team_id], name: :unique_game)

    create table(:player, primary_key: false) do
      add :id, :integer, primary_key: true
      add :name, :string
    end

    create table(:player_team, primary_key: false) do
      add :player_id, references(:player), primary_key: true
      add :team_id, references(:team), primary_key: true
    end
  end
end

defmodule TtMobile.Players do
  import Ecto.Query, warn: false
  alias TtMobile.Repo

  alias TtMobile.Players.Player
  alias TtMobile.Players.PlayerTeam

  def list_players do
    Repo.all(Player)
  end

  def get_player(id) do
    Repo.get!(Player, id)
  end

  def upsert_player(attrs) do
    %Player{}
    |> Player.changeset(attrs)
    |> Repo.insert(on_conflict: {:replace, [:name]}, conflict_target: [:id])
  end

  def upsert_player_team(player_id, team_id) do
    Repo.insert(%PlayerTeam{player_id: player_id, team_id: team_id}, on_conflict: :nothing)
  end
end

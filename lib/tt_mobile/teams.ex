defmodule TtMobile.Teams do
  import Ecto.Query, warn: false
  alias TtMobile.Repo

  alias TtMobile.Teams.Team

  def get_team!(id) do
    Repo.get!(Team, id) |> Repo.preload(:players)
  end

  def upsert_team(attrs) do
    %Team{}
    |> Team.changeset(attrs)
    |> Repo.insert(
      on_conflict:
        {:replace,
         [
           :name,
           :game_count,
           :win_count,
           :draw_count,
           :lose_count,
           :games_won,
           :games_lost,
           :points_won,
           :points_lost
         ]},
      conflict_target: [:id]
    )
  end
end

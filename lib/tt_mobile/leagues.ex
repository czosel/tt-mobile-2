defmodule TtMobile.Leagues do
  import Ecto.Query, warn: false
  alias TtMobile.Repo

  alias TtMobile.Leagues.League

  def get_league!(id) do
    # TODO separate methods for preloads?
    Repo.get!(League, id) |> Repo.preload([:association, :teams])
  end

  def get_team_by_name(league, name) do
    Enum.find(league.teams, fn team -> team.name == name end) |> IO.inspect()
  end

  def upsert_league(attrs) do
    %League{}
    |> League.changeset(attrs)
    |> Repo.insert(on_conflict: {:replace, [:name]}, conflict_target: [:id])
  end
end

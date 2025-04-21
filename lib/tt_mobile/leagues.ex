defmodule TtMobile.Leagues do
  import Ecto.Query, warn: false
  alias TtMobile.Repo

  alias TtMobile.Leagues.League

  def get_league!(id, opts \\ []) do
    League
    |> Repo.get!(id)
    |> Repo.preload(
      games:
        from(
          g in TtMobile.Games.Game,
          order_by: [asc: g.start]
        ),
      teams:
        from(
          t in TtMobile.Teams.Team,
          order_by: [desc: t.points_won, desc: t.games_won]
        )
    )
    |> Repo.preload(Keyword.get(opts, :preload, []))
  end

  def get_team_by_name(league, name) do
    Enum.find(league.teams, fn team -> team.name == name end)
  end

  def upsert_league(attrs) do
    %League{}
    |> League.changeset(attrs)
    |> Repo.insert(on_conflict: {:replace, [:name]}, conflict_target: [:id])
  end
end

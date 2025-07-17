defmodule TtMobile.Games do
  import Ecto.Query, warn: false
  alias TtMobile.Repo

  alias TtMobile.Games.Game

  def get_game!(id, opts \\ []) do
    Game
    |> Repo.get!(id)
    |> Repo.preload(Keyword.get(opts, :preload, []))
  end

  def upsert_game(attrs) do
    %Game{}
    |> Game.changeset(attrs)
    |> Repo.insert(
      on_conflict: {:replace, [:start, :result, :league_id, :home_team_id, :guest_team_id]},
      conflict_target: [:code]
    )
  end
end

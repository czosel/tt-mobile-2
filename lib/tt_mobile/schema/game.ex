defmodule TtMobile.Games.Game do
  use Ecto.Schema

  import Ecto.Changeset

  schema "game" do
    field :code, :string
    field :start, :naive_datetime
    belongs_to :league, TtMobile.Leagues.League
    belongs_to :home_team, TtMobile.Teams.Team
    belongs_to :guest_team, TtMobile.Teams.Team
    field :result, :string
  end

  def changeset(game, attrs) do
    game
    |> cast(attrs, [:code, :start, :result, :league_id, :home_team_id, :guest_team_id])
    |> validate_required([:start, :league_id, :home_team_id, :guest_team_id])
    |> unique_constraint(:code)
    |> unique_constraint(:unique_game, name: :unique_game)
  end
end

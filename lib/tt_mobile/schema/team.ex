defmodule TtMobile.Teams.Team do
  use Ecto.Schema

  import Ecto.Changeset

  @primary_key {:id, :integer, []}
  @derive {Phoenix.Param, key: :id}
  schema "team" do
    field :name, :string
    belongs_to :club, TtMobile.Clubs.Club
    belongs_to :league, TtMobile.Leagues.League
  end

  def changeset(team, attrs) do
    team
    |> cast(attrs, [:id, :name, :league_id, :club_id])
    |> validate_required([:name])
    |> unique_constraint(:id, name: :team_pkey)
  end
end

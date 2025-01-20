defmodule TtMobile.Teams.Team do
  use Ecto.Schema

  import Ecto.Changeset

  @primary_key {:id, :integer, []}
  @derive {Phoenix.Param, key: :id}
  schema "team" do
    field :name, :string
    belongs_to :club, TtMobile.Clubs.Club
    belongs_to :league, TtMobile.Leagues.League

    many_to_many :players, TtMobile.Players.Player,
      join_through: "player_team",
      on_replace: :delete

    field :game_count, :integer
    field :win_count, :integer
    field :draw_count, :integer
    field :lose_count, :integer
    field :games_won, :integer
    field :games_lost, :integer
    field :points_won, :integer
    field :points_lost, :integer
  end

  def changeset(team, attrs) do
    team
    |> cast(attrs, [
      :id,
      :name,
      :league_id,
      :club_id,
      :game_count,
      :win_count,
      :draw_count,
      :lose_count,
      :games_won,
      :games_lost,
      :points_won,
      :points_lost
    ])
    |> validate_required([:name])
    |> unique_constraint(:id, name: :team_pkey)
  end
end

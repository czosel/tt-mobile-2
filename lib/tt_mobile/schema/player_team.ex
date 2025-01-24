defmodule TtMobile.Players.PlayerTeam do
  use Ecto.Schema

  import Ecto.Changeset

  @primary_key false
  schema "player_team" do
    belongs_to :player, TtMobile.Players.Player, primary_key: true
    belongs_to :team, TtMobile.Teams.Team, primary_key: true
  end

  def changeset(player_team, attrs) do
    player_team
    |> cast(attrs, [:player_id, :team_id])
    |> validate_required([:player_id, :team_id])
    |> unique_constraint(:player_team, name: :player_team_pkey)
  end
end

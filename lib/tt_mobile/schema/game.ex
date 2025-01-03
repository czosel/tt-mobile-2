defmodule TtMobile.Games.Game do
  use Ecto.Schema

  import Ecto.Changeset

  @primary_key {:id, :integer, []}
  @derive {Phoenix.Param, key: :id}
  schema "game" do
    belongs_to :home_team, TtMobile.Teams.Team
    belongs_to :guest_team, TtMobile.Teams.Team
    field :result, :string
  end

  def changeset(game, attrs) do
    game
    |> cast(attrs, [:id, :result, :home_team_id, :guest_team_id])
    |> validate_required([:home_team_id, :guest_team_id])
    |> unique_constraint(:id, name: :game_pkey)
  end
end

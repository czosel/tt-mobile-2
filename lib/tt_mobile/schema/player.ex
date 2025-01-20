defmodule TtMobile.Players.Player do
  use Ecto.Schema

  import Ecto.Changeset

  @primary_key {:id, :integer, []}
  @derive {Phoenix.Param, key: :id}
  schema "player" do
    field :name, :string
    many_to_many :teams, TtMobile.Teams.Team, join_through: "player_team", on_replace: :delete
  end

  def changeset(player, attrs) do
    player
    |> cast(attrs, [:id, :name])
    |> cast_assoc(:teams)
    |> validate_required([:name])
    |> unique_constraint(:id, name: :player_pkey)
  end
end

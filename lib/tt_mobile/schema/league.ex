defmodule TtMobile.Leagues.League do
  use Ecto.Schema

  import Ecto.Changeset

  @primary_key {:id, :integer, []}
  @derive {Phoenix.Param, key: :id}
  schema "league" do
    field :name, :string
    belongs_to :association, TtMobile.Associations.Association
    has_many :teams, TtMobile.Teams.Team
  end

  def changeset(league, attrs) do
    league
    |> cast(attrs, [:id, :name, :association_id])
    |> validate_required([:name, :association_id])
    |> unique_constraint(:id, name: :league_pkey)
  end
end

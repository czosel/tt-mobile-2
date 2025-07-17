defmodule TtMobile.Associations.Association do
  use Ecto.Schema

  import Ecto.Changeset

  schema "association" do
    field :code, :string
    field :name, :string
    belongs_to :season, TtMobile.Seasons.Season
    has_many :leagues, TtMobile.Leagues.League
  end

  def changeset(association, attrs) do
    association
    |> cast(attrs, [:name, :code, :season_id])
    |> validate_required([:name, :code, :season_id])
    |> unique_constraint(:code)
  end
end

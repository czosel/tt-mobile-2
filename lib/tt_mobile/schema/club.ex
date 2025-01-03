defmodule TtMobile.Clubs.Club do
  use Ecto.Schema

  import Ecto.Changeset

  @primary_key {:id, :integer, []}
  @derive {Phoenix.Param, key: :id}
  schema "club" do
    field :name, :string
    has_many :teams, TtMobile.Teams.Team
  end

  def changeset(club, attrs) do
    club
    |> cast(attrs, [:id, :name])
    |> validate_required([:name])
    |> unique_constraint(:id, name: :club_pkey)
  end
end

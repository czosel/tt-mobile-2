defmodule TtMobile.Associations.Association do
  use Ecto.Schema

  import Ecto.Changeset

  schema "association" do
    field :code, :string
    field :name, :string
    has_many :leagues, TtMobile.Leagues.League
  end

  def changeset(association, attrs) do
    association
    |> cast(attrs, [:name, :code])
    |> validate_required([:name, :code])
    |> unique_constraint(:code)
  end
end

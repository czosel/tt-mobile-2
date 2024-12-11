defmodule TtMobile.League do
  use Ecto.Schema

  schema "league" do
    field :name, :string
    belongs_to :association, TtMobile.Association
  end
end

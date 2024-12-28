defmodule TtMobile.Association do
  use Ecto.Schema

  schema "association" do
    field :code, :string
    field :name, :string
    has_many :leagues, TtMobile.League
  end
end

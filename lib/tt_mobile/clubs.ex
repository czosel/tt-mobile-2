defmodule TtMobile.Clubs do
  import Ecto.Query, warn: false
  alias TtMobile.Repo

  alias TtMobile.Clubs.Club

  def list_clubs do
    Repo.all(Club)
  end

  def get_club(id) do
    Repo.get!(Club, id)
  end

  @doc """
  Creates a club.
  """
  def create_club(attrs) do
    %Club{}
    |> Club.changeset(attrs)
    |> Repo.insert()
  end
end

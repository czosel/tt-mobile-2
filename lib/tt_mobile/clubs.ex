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

  def upsert_club(attrs) do
    %Club{}
    |> Club.changeset(attrs)
    |> Repo.insert(on_conflict: {:replace, [:name]}, conflict_target: [:id])
  end
end

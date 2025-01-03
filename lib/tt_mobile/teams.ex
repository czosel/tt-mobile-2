defmodule TtMobile.Teams do
  import Ecto.Query, warn: false
  alias TtMobile.Repo

  alias TtMobile.Teams.Team

  def get_team!(id) do
    Repo.get!(Team, id)
  end

  @doc """
  Creates a team.
  """
  def create_team(attrs) do
    %Team{}
    |> Team.changeset(attrs)
    |> Repo.insert()
  end
end

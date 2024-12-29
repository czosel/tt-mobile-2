defmodule TtMobile.Leagues do
  import Ecto.Query, warn: false
  alias TtMobile.Repo

  alias TtMobile.Leagues.League

  def list_leagues do
    Repo.all(League)
  end

  def get_league(id) do
    Repo.get(League, id)
  end

  @doc """
  Creates a league.

  # Example

      iex> create_league(%{field: value})
      {:ok, %League{}}
  """
  def create_league(attrs) do
    %League{}
    |> League.changeset(attrs)
    |> Repo.insert()
  end
end

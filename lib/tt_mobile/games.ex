defmodule TtMobile.Games do
  import Ecto.Query, warn: false
  alias TtMobile.Repo

  alias TtMobile.Games.Game

  def get_game!(id) do
    Repo.get!(Game, id)
  end

  @doc """
  Creates a game.
  """
  def create_game(attrs) do
    %Game{}
    |> Game.changeset(attrs)
    |> Repo.insert()
  end
end

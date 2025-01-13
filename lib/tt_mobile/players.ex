defmodule TtMobile.Players do
  import Ecto.Query, warn: false
  alias TtMobile.Repo

  alias TtMobile.Players.Player

  def list_players do
    Repo.all(Player)
  end

  def get_player(id) do
    Repo.get!(Player, id)
  end

  def upsert_player(attrs) do
    %Player{}
    |> Player.changeset(attrs)
    |> Repo.insert(on_conflict: {:replace, [:name]}, conflict_target: [:id])
  end
end

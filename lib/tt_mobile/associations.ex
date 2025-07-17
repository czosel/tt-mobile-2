defmodule TtMobile.Associations do
  import Ecto.Query, warn: false
  alias TtMobile.Repo

  alias TtMobile.Associations.Association

  def list_current_associations() do
    from(
      a in Association,
      # TODO : remove hardcoded season_id
      where: a.season_id == 1,
      order_by: [asc: a.name]
    )
    |> Repo.all()
  end

  def get_association!(id) do
    Repo.get!(Association, id)
    |> Repo.preload(
      leagues:
        from(
          l in TtMobile.Leagues.League,
          order_by: [asc: l.sort]
        )
    )
    |> Repo.preload(:leagues)
  end

  def upsert_association(attrs) do
    %Association{}
    |> Association.changeset(attrs)
    |> Repo.insert(on_conflict: {:replace, [:name]}, conflict_target: [:code])
  end
end

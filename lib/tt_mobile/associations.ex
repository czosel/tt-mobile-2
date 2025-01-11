defmodule TtMobile.Associations do
  import Ecto.Query, warn: false
  alias TtMobile.Repo

  alias TtMobile.Associations.Association

  def list_associations do
    Repo.all(Association)
  end

  def get_association!(id) do
    Repo.get!(Association, id) |> Repo.preload(:leagues)
  end

  @doc """
  Upserts an association.

  ## Examples

      iex> upsert_association(%{field: value})
      {:ok, %Association{}}

      iex> upsert_association(%{field: bad_value})
      {:error, ...}

  """
  def upsert_association(attrs) do
    %Association{}
    |> Association.changeset(attrs)
    |> Repo.insert(on_conflict: {:replace, [:name]}, conflict_target: [:code])
  end
end

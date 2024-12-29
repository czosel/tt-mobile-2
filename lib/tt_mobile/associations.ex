defmodule TtMobile.Associations do
  import Ecto.Query, warn: false
  alias TtMobile.Repo

  alias TtMobile.Associations.Association

  def list_associations do
    Repo.all(Association)
  end

  def get_association!(id) do
    Repo.get(Association, id) |> Repo.preload(:leagues)
  end

  @doc """
  Creates a association.

  ## Examples

      iex> create_association(%{field: value})
      {:ok, %Association{}}

      iex> create_association(%{field: bad_value})
      {:error, ...}

  """
  def create_association(attrs \\ %{}) do
    %Association{}
    |> Association.changeset(attrs)
    |> Repo.insert()
  end
end

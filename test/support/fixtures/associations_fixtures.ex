defmodule TtMobile.AssociationsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `TtMobile.Associations` context.
  """

  alias TtMobile.Associations
  alias TtMobile.Seasons

  @doc """
  Generate a association.
  """
  def association_fixture(attrs \\ %{}) do
    {:ok, season} =
      attrs
      |> Enum.into(%{ name: "2024/25" })
      |> Seasons.upsert_season()

    {:ok, association} =
      attrs
      |> Enum.into(%{
        name: "Nationalliga 2024/25",
        code: "STT 24/25",
        season_id: season.id
      })
      |> Associations.upsert_association()

    association
  end
end

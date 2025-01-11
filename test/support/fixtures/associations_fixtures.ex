defmodule TtMobile.AssociationsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `TtMobile.Associations` context.
  """

  @doc """
  Generate a association.
  """
  def association_fixture(attrs \\ %{}) do
    {:ok, association} =
      attrs
      |> Enum.into(%{
        name: "Nationalliga 2024/25",
        code: "STT 24/25"
      })
      |> TtMobile.Associations.upsert_association()

    association
  end
end

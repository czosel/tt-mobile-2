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

      })
      |> TtMobile.Associations.create_association()

    association
  end
end

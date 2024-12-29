defmodule TtMobile.AssociationsTest do
  use TtMobile.DataCase

  alias TtMobile.Associations

  describe "associations" do
    alias TtMobile.Associations.Association

    import TtMobile.AssociationsFixtures

    @invalid_attrs %{}

    test "list_associations/0 returns all associations" do
      association = association_fixture()
      assert Associations.list_associations() |> Enum.map(& &1.name) == [association.name]
    end

    test "get_association!/1 returns the association with given id" do
      association = association_fixture()
      assert Associations.get_association!(association.id).name == association.name
    end
  end
end

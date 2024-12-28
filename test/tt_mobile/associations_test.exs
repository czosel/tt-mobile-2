defmodule TtMobile.AssociationsTest do
  use TtMobile.DataCase

  alias TtMobile.Associations

  describe "associations" do
    alias TtMobile.Associations.Association

    import TtMobile.AssociationsFixtures

    @invalid_attrs %{}

    test "list_associations/0 returns all associations" do
      association = association_fixture()
      assert Associations.list_associations() == [association]
    end

    test "get_association!/1 returns the association with given id" do
      association = association_fixture()
      assert Associations.get_association!(association.id) == association
    end

    test "create_association/1 with valid data creates a association" do
      valid_attrs = %{}

      assert {:ok, %Association{} = association} = Associations.create_association(valid_attrs)
    end

    test "create_association/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Associations.create_association(@invalid_attrs)
    end

    test "update_association/2 with valid data updates the association" do
      association = association_fixture()
      update_attrs = %{}

      assert {:ok, %Association{} = association} = Associations.update_association(association, update_attrs)
    end

    test "update_association/2 with invalid data returns error changeset" do
      association = association_fixture()
      assert {:error, %Ecto.Changeset{}} = Associations.update_association(association, @invalid_attrs)
      assert association == Associations.get_association!(association.id)
    end

    test "delete_association/1 deletes the association" do
      association = association_fixture()
      assert {:ok, %Association{}} = Associations.delete_association(association)
      assert_raise Ecto.NoResultsError, fn -> Associations.get_association!(association.id) end
    end

    test "change_association/1 returns a association changeset" do
      association = association_fixture()
      assert %Ecto.Changeset{} = Associations.change_association(association)
    end
  end
end

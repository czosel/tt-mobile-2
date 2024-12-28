defmodule TtMobileWeb.AssociationLiveTest do
  use TtMobileWeb.ConnCase

  import Phoenix.LiveViewTest
  import TtMobile.AssociationsFixtures

  @create_attrs %{}
  @update_attrs %{}
  @invalid_attrs %{}

  defp create_association(_) do
    association = association_fixture()
    %{association: association}
  end

  describe "Index" do
    setup [:create_association]

    test "lists all associations", %{conn: conn} do
      {:ok, _index_live, html} = live(conn, ~p"/associations")

      assert html =~ "Listing Associations"
    end

    test "saves new association", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/associations")

      assert index_live |> element("a", "New Association") |> render_click() =~
               "New Association"

      assert_patch(index_live, ~p"/associations/new")

      assert index_live
             |> form("#association-form", association: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#association-form", association: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/associations")

      html = render(index_live)
      assert html =~ "Association created successfully"
    end

    test "updates association in listing", %{conn: conn, association: association} do
      {:ok, index_live, _html} = live(conn, ~p"/associations")

      assert index_live |> element("#associations-#{association.id} a", "Edit") |> render_click() =~
               "Edit Association"

      assert_patch(index_live, ~p"/associations/#{association}/edit")

      assert index_live
             |> form("#association-form", association: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#association-form", association: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/associations")

      html = render(index_live)
      assert html =~ "Association updated successfully"
    end

    test "deletes association in listing", %{conn: conn, association: association} do
      {:ok, index_live, _html} = live(conn, ~p"/associations")

      assert index_live |> element("#associations-#{association.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#associations-#{association.id}")
    end
  end

  describe "Show" do
    setup [:create_association]

    test "displays association", %{conn: conn, association: association} do
      {:ok, _show_live, html} = live(conn, ~p"/associations/#{association}")

      assert html =~ "Show Association"
    end

    test "updates association within modal", %{conn: conn, association: association} do
      {:ok, show_live, _html} = live(conn, ~p"/associations/#{association}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Association"

      assert_patch(show_live, ~p"/associations/#{association}/show/edit")

      assert show_live
             |> form("#association-form", association: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#association-form", association: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/associations/#{association}")

      html = render(show_live)
      assert html =~ "Association updated successfully"
    end
  end
end

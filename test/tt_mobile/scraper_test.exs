defmodule TtMobile.ScraperTest do
  use TtMobile.DataCase

  alias TtMobile.Repo
  alias TtMobile.Associations.Association
  alias TtMobile.Leagues.League
  alias TtMobile.Scraper

  alias TtMobile.AssociationsFixtures

  @tag :query_param
  test "query param extraction" do
    url = "http://example.com?foo=bar&baz=qux"
    assert Scraper.extract_query_param(url, "foo") == "bar"
  end

  @tag :all_associations
  test "associations scraping" do
    AssociationsFixtures.association_fixture()
    assocs = Scraper.associations()
    assert length(assocs) == 9
    assert Enum.at(assocs, 0).name =~ "Nationalliga"
    assert Repo.aggregate(Association, :count, :id) == 9

    # DB unchanged after scraping again
    Scraper.associations()
    assert Repo.aggregate(Association, :count, :id) == 9
  end

  @tag :association
  test "association scraping" do
    assoc = AssociationsFixtures.association_fixture()
    Scraper.association(assoc.id)
    assert Repo.aggregate(League, :count, :id) == 10

    # DB unchanged after scraping again
    Scraper.association(assoc.id)
    assert Repo.aggregate(League, :count, :id) == 10
  end

  test "club scraping" do
    %{:data => data, :club_id => club_id} = Scraper.club("33122")
    assert club_id == "33122"
    assert length(data) == 2
  end
end

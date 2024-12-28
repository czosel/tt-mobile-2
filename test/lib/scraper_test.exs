defmodule TtMobile.ScraperTest do
  use TtMobile.DataCase

  @tag :query_param
  test "query param extraction" do
    url = "http://example.com?foo=bar&baz=qux"
    assert TtMobile.Scraper.extract_query_param(url, "foo") == "bar"
  end

  @tag :all_associations
  test "associations scraping" do
    TtMobile.Repo.insert!(%TtMobile.Association{
      name: "Nationalliga 2024/25",
      code: "STT 24/25"
    })
    assocs = TtMobile.Scraper.associations()
    assert length(assocs) > 0
    assert Enum.at(assocs, 0).name =~ "Nationalliga"
    count = TtMobile.Repo.aggregate(TtMobile.Association, :count, :id)
    assert count == 9
  end

  @tag :association
  test "association scraping" do
    TtMobile.Repo.insert!(%TtMobile.Association{id: 1, name: "Nationalliga 2024/25"})
    assert TtMobile.Scraper.association(1) == "foo"
  end

  test "club scraping" do
    %{:data => data, :club_id => club_id } = TtMobile.Scraper.club("33122")
    assert club_id == "33122"
    assert length(data) == 2
  end

end

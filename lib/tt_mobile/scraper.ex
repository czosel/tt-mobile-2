require Floki
require String
require URI

import Ecto.Query, only: [from: 2]

defmodule TtMobile.Scraper do
  @root_url "https://www.click-tt.ch"
  @base_url "#{@root_url}/cgi-bin/WebObjects/nuLigaTTCH.woa/wa/"

  defp text(dom) do
    dom |> Floki.text() |> String.trim()
  end

  def region_schedule(championship, date \\ Date.utc_today()) do
    url = "#{@base_url}regionMeetingFilter"
    monday = Date.beginning_of_week(date)
    day_of_year = Date.day_of_year(monday)
    month = (Calendar.strftime(monday, "%m") |> String.to_integer()) - 1

    response = HTTPoison.post!(url, {:form, [
      {:championship, championship},
      {:month, month},
      {:dayOfYear, day_of_year},
      {:filterHomeGuestBackup, :false}
    ]})

    # still WIP
    data =
      response.body
      |> Floki.find("table.result-set > tr:not(:first-child)")
      |> Enum.map(&Floki.children/1)
    data
  end

  def extract_query_param(url, key) do
    url
    |> URI.parse()
    |> Map.get(:query)
    |> URI.decode_query()
    |> Map.get(key)
  end

  def associations() do
    response = HTTPoison.get!("#{@root_url}/index.htm.de")
    assocs = response.body
      |> Floki.find("div#navigation li strong:fl-contains('Spielbetrieb') + ul li a")
      |> Enum.map(fn link ->
        %{
          code: link
            |> Floki.attribute("href")
            |> Enum.at(0)
            |> extract_query_param("championship"),
          name: link |> text()
        }
        end)

    found_codes = Enum.map(assocs, &(&1.code))

    existing = TtMobile.Repo.all(
      from a in "association",
      where: a.code in ^found_codes,
      select: a.code
    )
    assocs
      |> Enum.filter(fn a -> a.code not in existing end)
      |> Enum.each(fn assoc ->
        TtMobile.Repo.insert!(struct(TtMobile.Association, assoc))
      end)

    assocs
  end

  def association(assoc_id) do
    code = TtMobile.Repo.get(TtMobile.Association, assoc_id).code

    url = "#{@base_url}leaguePage?championship=#{URI.encode(code)}"
    response = HTTPoison.get!(url)

    leagues =
      response.body
      |> Floki.find("table.matrix td ul li span a")
      |> Enum.map(fn link ->
        %{
          id: link
            |> Floki.attribute("href")
            |> Enum.at(0)
            |> extract_query_param("group")
            |> String.to_integer(),
          name: link |> text(),
          association_id: String.to_integer(assoc_id)
        }
      end)

    found_leagues = Enum.map(leagues, &(&1.id))

    existing = TtMobile.Repo.all(
      from l in "league",
      where: l.id in ^found_leagues,
      select: l.id
    )
    leagues
      |> Enum.filter(fn l -> l.id not in existing end)
      |> Enum.each(fn league ->
        TtMobile.Repo.insert!(struct(TtMobile.League, league))
      end)

    assoc_id
  end

  def club(club_id) do
    url = "#{@base_url}clubInfoDisplay?club=#{club_id}"
    response = HTTPoison.get!(url)

    data =
      response.body
      |> Floki.find("h2:fl-contains('Rückschau') + table tr")
      # remove table head
      |> tl
      |> Enum.map(&Floki.children/1)
      |> Enum.map(fn row ->
        %{
          home: row |> Enum.at(6) |> text,
          guest: row |> Enum.at(8) |> text,
          result: row |> Enum.at(10) |> text,
          href: row |> Enum.at(10) |> Floki.attribute("a", "href") |> Enum.at(0)
        }
      end)

    name =
      response.body
      |> Floki.find("h1")
      |> Enum.map(&Floki.children/1)
      |> Enum.at(0)
      |> Enum.at(2)
      |> String.trim()

    TtMobile.Repo.insert!(
      %TtMobile.Club{id: club_id |> String.to_integer(), name: name},
      on_conflict: [set: [name: name]],
      conflict_target: :id
    )

    %{
      club_id: club_id,
      data: data
    }
  end
end

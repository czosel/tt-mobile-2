require Floki
require String
require URI

import Ecto.Query, only: [from: 2]

defmodule TtMobile.Scraper do
  @root_url "https://www.click-tt.ch"
  @base_url "#{@root_url}/cgi-bin/WebObjects/nuLigaTTCH.woa/wa/"

  alias TtMobile.Repo
  alias TtMobile.Leagues
  alias TtMobile.Associations
  alias TtMobile.Teams
  alias TtMobile.Games

  defp text(dom) do
    dom |> Floki.text() |> String.trim()
  end

  def region_schedule(championship, date \\ Date.utc_today()) do
    url = "#{@base_url}regionMeetingFilter"
    monday = Date.beginning_of_week(date)
    day_of_year = Date.day_of_year(monday)
    month = (Calendar.strftime(monday, "%m") |> String.to_integer()) - 1

    response =
      HTTPoison.post!(
        url,
        {:form,
         [
           {:championship, championship},
           {:month, month},
           {:dayOfYear, day_of_year},
           {:filterHomeGuestBackup, false}
         ]}
      )

    # still WIP
    data =
      response.body
      |> Floki.find("table.result-set > tr:not(:first-child)")
      |> Enum.map(&Floki.children/1)

    data
  end

  def extract_query_param(nil, _), do: nil

  def extract_query_param(url, key) do
    url
    |> URI.parse()
    |> Map.get(:query)
    |> URI.decode_query()
    |> Map.get(key)
  end

  def associations() do
    response = HTTPoison.get!("#{@root_url}/index.htm.de")

    assocs =
      response.body
      |> Floki.find("div#navigation li strong:fl-contains('Spielbetrieb') + ul li a")
      |> Enum.map(fn link ->
        %{
          code:
            link
            |> Floki.attribute("href")
            |> Enum.at(0)
            |> extract_query_param("championship"),
          name: link |> text()
        }
      end)

    Enum.each(assocs, fn assoc ->
      Associations.create_association(assoc)
    end)

    assocs
  end

  def association(assoc_id) do
    %{code: code} = Associations.get_association!(assoc_id)

    url = "#{@base_url}leaguePage?championship=#{URI.encode(code)}"
    response = HTTPoison.get!(url)

    response.body
    |> Floki.find("table.matrix td ul li span a")
    |> Enum.map(fn link ->
      %{
        id:
          link
          |> Floki.attribute("href")
          |> Enum.at(0)
          |> extract_query_param("group")
          |> String.to_integer(),
        name: link |> text(),
        association_id: assoc_id
      }
    end)
    |> Enum.map(&Leagues.create_league/1)

    assoc_id
  end

  def league_schedule(league_id) do
    league = Leagues.get_league!(league_id)

    url =
      "#{@base_url}groupPage?displayTyp=gesamt&displayDetail=meetings&championship=#{URI.encode(league.association.code)}&group=#{league_id}"

    response = HTTPoison.get!(url)

    data =
      response.body
      |> Floki.find("table.result-set > tr:not(:first-child)")
      |> Enum.map(&Floki.children/1)
      |> Enum.map(fn row ->
        %{
          code:
            row
            |> Enum.at(9)
            |> Floki.attribute("a", "href")
            |> Enum.at(0)
            |> extract_query_param("meeting"),
          date: row |> Enum.at(1) |> text,
          time: row |> Enum.at(2) |> text,
          home: row |> Enum.at(5) |> text,
          guest: row |> Enum.at(7) |> text,
          result: row |> Enum.at(9) |> text
        }
      end)
      |> fill_dates()
      |> Enum.map(fn attrs ->
        home_team = Leagues.get_team_by_name(league, attrs.home)
        guest_team = Leagues.get_team_by_name(league, attrs.guest)

        %{
          code: attrs.code,
          start: to_naive_datetime(attrs.date, attrs.time),
          home_team_id: home_team.id,
          guest_team_id: guest_team.id,
          result: attrs.result
        }
      end)
      |> IO.inspect()
      |> Enum.map(&Games.create_game/1)

    league_id
  end

  def to_naive_datetime(
        <<dd::binary-2, ".", mm::binary-2, ".", yyyy::binary-4>>,
        <<h::binary-2, ":", m::binary-2>> <> _rest
      ) do
    [yyyy, mm, dd, h, m] = for i <- [yyyy, mm, dd, h, m], do: String.to_integer(i)
    NaiveDateTime.new!(yyyy, mm, dd, h, m, 0)
  end

  def league_teams(league_id) do
    league = Leagues.get_league!(league_id)

    url =
      "#{@base_url}groupPage?displayTyp=gesamt&displayDetail=table&championship=#{URI.encode(league.association.code)}&group=#{league_id}"

    response = HTTPoison.get!(url)

    response.body
    |> Floki.find("table.result-set > tr:not(:first-child)")
    |> Enum.map(&Floki.children/1)
    |> Enum.map(fn row ->
      %{
        id:
          row
          |> Enum.at(2)
          |> Floki.attribute("a", "href")
          |> Enum.at(0)
          |> extract_query_param("teamtable"),
        name: row |> Enum.at(2) |> text,
        league_id: league_id
      }
    end)
    |> Enum.map(&Teams.create_team/1)

    league_id
  end

  def league(league_id) do
    league_id
    |> league_teams()
    |> league_schedule()
  end

  defp fill_dates(data) do
    # infer missing dates from previous row
    data
    |> Enum.with_index()
    |> Enum.reduce([], fn {row, index}, acc ->
      if row.date == "" do
        [%{row | date: Enum.at(acc, 0).date} | acc]
      else
        [row | acc]
      end
    end)
    |> Enum.reverse()
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

    # TODO use context
    Repo.insert!(
      %TtMobile.Clubs.Club{id: club_id |> String.to_integer(), name: name},
      on_conflict: [set: [name: name]],
      conflict_target: :id
    )

    %{
      club_id: club_id,
      data: data
    }
  end
end

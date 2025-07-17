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
  alias TtMobile.Players

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
    |> Enum.map(&Associations.upsert_association/1)
  end

  def association(assoc_id) do
    %{code: code} = Associations.get_association!(assoc_id)

    url = "#{@base_url}leaguePage?championship=#{URI.encode(code)}"
    response = HTTPoison.get!(url)

    response.body
    |> Floki.find("table.matrix td ul li span a")
    |> Enum.with_index()
    |> Enum.map(fn {link, sort} ->
      %{
        id:
          link
          |> Floki.attribute("href")
          |> Enum.at(0)
          |> extract_query_param("group")
          |> String.to_integer(),
        name: link |> text(),
        association_id: assoc_id,
        sort: sort
      }
    end)
    |> Enum.map(&Leagues.upsert_league/1)

    assoc_id
  end

  def league_schedule(league) do
    url =
      "#{@base_url}groupPage?displayTyp=gesamt&displayDetail=meetings&championship=#{URI.encode(league.association.code)}&group=#{league.id}"

    response = HTTPoison.get!(url)

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
        league_id: league.id,
        home_team_id: if(home_team, do: home_team.id, else: nil),
        guest_team_id: if(guest_team, do: guest_team.id, else: nil),
        result: attrs.result
      }
    end)
    |> Enum.map(&Games.upsert_game/1)

    league
  end

  def to_naive_datetime(
        <<dd::binary-2, ".", mm::binary-2, ".", yyyy::binary-4>>,
        <<h::binary-2, ":", m::binary-2>> <> _rest
      ) do
    [yyyy, mm, dd, h, m] = for i <- [yyyy, mm, dd, h, m], do: String.to_integer(i)
    NaiveDateTime.new!(yyyy, mm, dd, h, m, 0)
  end

  def league_table(league) do
    url =
      "#{@base_url}groupPage?displayTyp=gesamt&displayDetail=table&championship=#{URI.encode(league.association.code)}&group=#{league.id}"

    response = HTTPoison.get!(url)

    response.body
    |> Floki.find("table.result-set > tr:not(:first-child)")
    |> Enum.map(&Floki.children/1)
    |> Enum.map(fn row ->
      [games_won, games_lost] =
        row
        |> Enum.at(7)
        |> text()
        |> String.split(":")
        |> Enum.map(&String.to_integer/1)

      [points_won, points_lost] =
        row
        |> Enum.at(9)
        |> text()
        |> String.split(":")
        |> Enum.map(&String.to_integer/1)

      %{
        id:
          row
          |> Enum.at(2)
          |> Floki.attribute("a", "href")
          |> Enum.at(0)
          |> extract_query_param("teamtable"),
        name: row |> Enum.at(2) |> text,
        game_count: row |> Enum.at(3) |> text,
        win_count: row |> Enum.at(4) |> text,
        draw_count: row |> Enum.at(5) |> text,
        lose_count: row |> Enum.at(6) |> text,
        games_won: games_won,
        games_lost: games_lost,
        points_won: points_won,
        points_lost: points_lost,
        league_id: league.id
      }
    end)
    |> Enum.map(&Teams.upsert_team/1)

    league
  end

  def league(league_id) do
    league_id
    |> Leagues.get_league!(preload: [:association, :teams])
    |> league_table()
    |> league_schedule()
    |> Map.fetch!(:id)
  end

  defp fill_dates(data) do
    # infer missing dates from previous row
    data
    |> Enum.with_index()
    |> Enum.reduce([], fn {row, _}, acc ->
      if row.date == "" do
        [%{row | date: Enum.at(acc, 0).date} | acc]
      else
        [row | acc]
      end
    end)
    |> Enum.reverse()
  end

  def team(team_id) do
    url = "#{@base_url}teamPortrait?teamtable=#{team_id}"
    response = HTTPoison.get!(url)

    players =
      response.body
      |> Floki.find("#content-row2 table.result-set:last-of-type tr")
      |> Enum.map(&Floki.children/1)
      |> Enum.filter(fn row ->
        maybe_link = Enum.at(row, 1) |> Floki.children() |> Enum.at(0)

        case is_tuple(maybe_link) do
          false -> false
          true -> maybe_link |> elem(0) == "a"
        end
      end)
      |> Enum.map(fn row ->
        name = row |> Enum.at(1)

        %{
          id:
            name
            |> Floki.children()
            |> Enum.at(0)
            |> Floki.attribute("href")
            |> Enum.at(0)
            |> extract_query_param("person")
            |> String.to_integer(),
          name: name |> text,
          team_id: team_id
          # classification: row |> Enum.at(2) |> text
        }
      end)

    players
    |> Enum.map(&Players.upsert_player/1)

    players
    |> Enum.map(fn pl -> Players.upsert_player_team(pl.id, String.to_integer(team_id)) end)

    team_id
  end

  def game(game_id) do
    game = Games.get_game!(game_id, preload: [league: :association])
    league = game.league

    IO.puts("Fetching game #{game_id} for league #{league.id}")

    url =
      "#{@base_url}groupMeetingReport?meeting=#{game_id}&championship=#{URI.encode(league.association.code)}&group=#{league.id}"

    response = HTTPoison.get!(url)

    IO.inspect(response, label: "Response")

    data =
      response.body
      |> Floki.find("table.result-set > tr:not(:first-child)")
      |> Enum.map(&Floki.children/1)
      |> Enum.map(fn row ->
        %{
          home: row |> Enum.at(2) |> text,
          guest: row |> Enum.at(4) |> text,
          result: row |> Enum.at(6) |> text
        }
      end)

    %{
      game_id: game_id,
      data: data
    }
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

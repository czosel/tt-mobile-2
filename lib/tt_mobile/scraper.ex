require Floki
require String

defmodule TtMobile.Scraper do
  @base_url "https://www.click-tt.ch/cgi-bin/WebObjects/nuLigaTTCH.woa/wa/"

  def text(dom) do
    dom |> Floki.text() |> String.trim()
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

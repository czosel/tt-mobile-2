defmodule TtMobileWeb.LeagueLive do
  use TtMobileWeb, :live_view

  alias TtMobile.Leagues
  alias TtMobile.Repo
  alias TtMobile.Scraper

  def render(assigns) do
    ~H"""
    <div :if={@league}>
      <h1>{@league.name}</h1>
    </div>
    """
  end

  def handle_params(params, _uri, socket) do
    league_id = params["league_id"]

    {
      :noreply,
      socket
      |> assign_league(league_id)
      |> start_async(:scrape, fn -> Scraper.league(league_id) end)
    }
  end

  def handle_async(:scrape, {:ok, league_id}, socket) do
    {:noreply,
     socket
     |> assign_league(league_id)}
  end

  def handle_async(:scrape, {:exit, reason}, socket) do
    dbg(reason)

    {:noreply, socket}
  end

  defp assign_league(socket, league_id) do
    league = Leagues.get_league!(league_id)

    socket
    |> assign(league: league)
  end
end

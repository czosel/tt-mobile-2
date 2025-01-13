defmodule TtMobileWeb.LeagueLive do
  use TtMobileWeb, :live_view

  alias TtMobile.Leagues
  alias TtMobile.Scraper

  def render(assigns) do
    ~H"""
    <div :if={@league}>
      <h1>{@league.name}</h1>
      <table>
        <thead>
          <tr>
            <th></th>
            <th>Mannschaft</th>
            <th>Beg.</th>
            <th>S</th>
            <th>U</th>
            <th>N</th>
            <th>Spiele</th>
            <th>+/-</th>
            <th>Punkte</th>
          </tr>
        </thead>
        <tbody>
          <%= for team <- @league.teams do %>
            <tr>
              <td></td>
              <td>
                <.link navigate={~p"/team/#{team.id}"}>{team.name}</.link>
              </td>
              <td>{team.game_count}</td>
              <td>{team.win_count}</td>
              <td>{team.draw_count}</td>
              <td>{team.lose_count}</td>
              <td>{team.games_won}:{team.games_lost}</td>
              <td>{team.games_won - team.games_lost}</td>
              <td>{team.points_won}:{team.points_lost}</td>
            </tr>
          <% end %>
        </tbody>
      </table>
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

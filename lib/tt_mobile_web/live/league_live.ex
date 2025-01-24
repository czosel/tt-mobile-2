defmodule TtMobileWeb.LeagueLive do
  use TtMobileWeb, :live_view

  alias TtMobile.Leagues
  alias TtMobile.Scraper

  def render(assigns) do
    ~H"""
    <div :if={@league}>
      <h1>{@league.name}</h1>

      <.link patch={~p"/league/#{@league.id}"}>Tabelle</.link>
      <.link patch={~p"/league/#{@league.id}?show=schedule"}>Spielplan</.link>

      <.league_table :if={@show == "table"} league={@league} />
      <.league_schedule :if={@show == "schedule"} league={@league} />
    </div>
    """
  end

  def league_table(assigns) do
    ~H"""
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
    """
  end

  def league_schedule(assigns) do
    ~H"""
    <table>
      <thead>
        <tr>
          <th>Datum</th>
          <th>Heim</th>
          <th>Gast</th>
          <th>Ergebnis</th>
        </tr>
      </thead>
      <tbody>
        <%= for game <- @league.games do %>
          <tr>
            <td>{game.start}</td>
            <td>
              <.link navigate={~p"/team/#{game.home_team.id}"}>{game.home_team.name}</.link>
            </td>
            <td>
              <.link navigate={~p"/team/#{game.guest_team.id}"}>{game.guest_team.name}</.link>
            </td>
            <td>{game.result}</td>
          </tr>
        <% end %>
      </tbody>
    </table>
    """
  end

  def handle_params(params, _uri, socket) do
    league_id = params["league_id"]

    socket =
      case params["show"] do
        "schedule" -> socket |> assign(show: "schedule")
        _ -> socket |> assign(show: "table")
      end

    {
      :noreply,
      socket
      |> assign_data(league_id)
      |> start_async(:scrape, fn -> Scraper.league(league_id) end)
    }
  end

  def handle_async(:scrape, {:ok, league_id}, socket) do
    {:noreply,
     socket
     |> assign_data(league_id)}
  end

  def handle_async(:scrape, {:exit, reason}, socket) do
    dbg(reason)

    {:noreply, socket}
  end

  defp assign_data(socket, league_id) do
    league =
      Leagues.get_league!(league_id,
        preload: [:association, :teams, games: [:home_team, :guest_team]]
      )

    socket
    |> assign(league: league)
  end
end

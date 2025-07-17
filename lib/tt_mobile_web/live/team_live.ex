defmodule TtMobileWeb.TeamLive do
  use TtMobileWeb, :live_view

  alias TtMobile.Teams

  def render(assigns) do
    ~H"""
    <div :if={@team}>
      <h1>{@team.name}</h1>
      <table>
        <tr :for={player <- @team.players}>
          <td><.link navigate={~p"/player/#{player.id}"}>{player.name}</.link></td>
        </tr>
      </table>
    </div>
    """
  end

  def handle_params(params, _uri, socket) do
    team_id = params["team_id"]

    {
      :noreply,
      socket
      |> assign_team(team_id)
      |> start_async(:scrape, fn -> TtMobile.Scraper.team(team_id) end)
    }
  end

  def handle_async(:scrape, {:ok, team_id}, socket) do
    {:noreply, socket |> assign_team(team_id)}
  end

  # def handle_async(:scrape, {:exit, reason}, socket) do
  #   dbg(reason)

  #   {:noreply, socket}
  # end

  defp assign_team(socket, team_id) do
    socket
    |> assign(team: Teams.get_team!(team_id))
  end
end

defmodule TtMobileWeb.PlayerLive do
  use TtMobileWeb, :live_view

  alias TtMobile.Players

  def render(assigns) do
    ~H"""
    <div :if={@player}>
      <h1>{@player.name}</h1>
    </div>
    """
  end

  def handle_params(params, _uri, socket) do
    player_id = params["player_id"]

    {
      :noreply,
      socket
      |> assign_data(player_id)
      # |> start_async(:scrape, fn -> TtMobile.Scraper.team(team_id) end)
    }
  end

  def handle_async(:scrape, {:ok, player_id}, socket) do
    {:noreply, socket |> assign_data(player_id)}
  end

  def handle_async(:scrape, {:exit, reason}, socket) do
    dbg(reason)

    {:noreply, socket}
  end

  defp assign_data(socket, player_id) do
    socket
    |> assign(player: Players.get_player(player_id))
  end
end

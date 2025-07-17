defmodule TtMobileWeb.GameLive do
  use TtMobileWeb, :live_view

  alias TtMobile.Games

  def render(assigns) do
    ~H"""
    <div :if={@game}>
      <h1>{@game.home_team.name} - {@game.guest_team.name}</h1>
    </div>
    """
  end

  def handle_params(params, _uri, socket) do
    game_id = params["game_id"]

    {
      :noreply,
      socket
      |> assign_game(game_id)
      |> start_async(:scrape, fn -> TtMobile.Scraper.game(game_id) end)
    }
  end

  def handle_async(:scrape, {:ok, game_id}, socket) do
    {:noreply, socket |> assign_game(game_id)}
  end

  defp assign_game(socket, game_id) do
    socket
    |> assign(game: Games.get_game!(game_id, preload: [:home_team, :guest_team]))
  end
end

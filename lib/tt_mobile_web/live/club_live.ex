defmodule TtMobileWeb.ClubLive do
  use TtMobileWeb, :live_view

  def render(assigns) do
    ~H"""
    <div :if={@club}>
      <h1>{@club.name}</h1>
      <h2>Rückschau</h2>
      <table>
        <tr :for={row <- @data}>
          <td>{row.home}</td>
          <td>{row.guest}</td>
          <td>{row.result}</td>
        </tr>
      </table>
    </div>
    """
  end

  def handle_params(params, _uri, socket) do
    club_id = params["club_id"]

    {:noreply,
     socket
     |> assign_club(club_id)
     |> assign(:data, [])
     |> start_async(:scrape, fn -> TtMobile.Scraper.club(club_id) end)}
  end

  def handle_async(:scrape, {:ok, %{club_id: club_id, data: data}}, socket) do
    {:noreply,
     socket
     |> assign_club(club_id)
     |> assign(:data, data)
    }
  end

  def handle_async(:scrape, {:exit, reason}, socket) do
    dbg(reason)

    {:noreply, socket}
  end


  defp assign_club(socket, club_id) do
    socket
    |> assign(club: TtMobile.Repo.get(TtMobile.Club, club_id))
  end
end

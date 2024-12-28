defmodule TtMobileWeb.HomeLive do
  use TtMobileWeb, :live_view

  def render(assigns) do
    ~H"""
    Associations
    <ul>
      <li :for={assoc <- @associations}>
        <.link patch={~p"/assoc/#{assoc.id}"}>{assoc.name}</.link>
      </li>
    </ul>
    """
  end

  def mount(_params, _session, socket) do
    {:ok, socket
      |> assign_associations()
      |> start_async(:scrape, fn -> TtMobile.Scraper.associations() end)
    }
  end

  def handle_async(:scrape, {:ok, _data}, socket) do
    {:noreply,
     socket
     |> assign_associations()
    }
  end

  def handle_async(:scrape, {:exit, reason}, socket) do
    dbg(reason)

    {:noreply, socket}
  end

  def assign_associations(socket) do
    associations = TtMobile.Repo.all(TtMobile.Association)
    socket
      |> assign(associations: associations)
  end

end

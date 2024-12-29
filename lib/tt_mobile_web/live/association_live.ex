defmodule TtMobileWeb.AssociationLive do
  use TtMobileWeb, :live_view

  alias TtMobile.Associations
  alias TtMobile.Repo
  alias TtMobile.Scraper

  def render(assigns) do
    ~H"""
    <div :if={@assoc}>
      <h1>{@assoc.name}</h1>
      <ul>
        <li :for={league <- @assoc.leagues}>
          {league.name}
        </li>
      </ul>
    </div>
    """
  end

  def handle_params(params, _uri, socket) do
    assoc_id = params["assoc_id"]

    {:noreply,
     socket
     |> assign_assoc(assoc_id)
     |> start_async(:scrape, fn -> Scraper.association(assoc_id) end)}
  end

  def handle_async(:scrape, {:ok, assoc_id}, socket) do
    {:noreply,
     socket
     |> assign_assoc(assoc_id)}
  end

  def handle_async(:scrape, {:exit, reason}, socket) do
    dbg(reason)

    {:noreply, socket}
  end

  defp assign_assoc(socket, assoc_id) do
    assoc = Associations.get_association!(assoc_id)

    socket
    |> assign(assoc: assoc)
  end
end

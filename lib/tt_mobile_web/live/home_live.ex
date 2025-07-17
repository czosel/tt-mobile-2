defmodule TtMobileWeb.HomeLive do
  use TtMobileWeb, :live_view

  alias TtMobile.Associations

  def render(assigns) do
    ~H"""
    <.card>
      <:header>Punktspiele</:header>
      <ul>
        <.listlink :for={assoc <- @associations} navigate={~p"/assoc/#{assoc.id}"}>
          {assoc.name}
        </.listlink>
      </ul>
    </.card>
    """
  end

  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign_associations()
     |> start_async(:scrape, fn -> TtMobile.Scraper.associations() end)}
  end

  def handle_async(:scrape, {:ok, _data}, socket) do
    {:noreply,
     socket
     |> assign_associations()}
  end

  def handle_async(:scrape, {:exit, reason}, socket) do
    dbg(reason)

    {:noreply, socket}
  end

  def assign_associations(socket) do
    associations = Associations.list_current_associations()

    socket
    |> assign(associations: associations)
  end
end

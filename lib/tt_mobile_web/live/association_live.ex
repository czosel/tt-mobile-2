defmodule TtMobileWeb.AssociationLive do
  use TtMobileWeb, :live_view

  def render(assigns) do
    ~H"""
    Associations
    <ul>
      <li :for={assoc <- @associations}>{assoc.name}</li>
    </ul>
    """
  end

  def mount(_params, _session, socket) do
    associations = TtMobile.Repo.all(TtMobile.Association)
    {:ok, socket |> assign(:associations, associations)}
  end

end

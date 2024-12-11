defmodule TtMobileWeb.LeagueHTML do
  use TtMobileWeb, :html

  def index(assigns) do
    ~H"""
    Hello {@league}!
    """
  end
end

defmodule TtMobileWeb.LeagueController do
  use TtMobileWeb, :controller

  def index(conn, %{"league" => league}) do
    render(conn, :index, league: league)
  end
end

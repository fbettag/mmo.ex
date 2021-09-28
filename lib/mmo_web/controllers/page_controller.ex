defmodule MMOWeb.PageController do
  use MMOWeb, :controller

  def index(conn, %{"name" => name}) do
    redirect(conn, to: Routes.game_path(conn, :play, name: name))
  end

  def index(conn, _params) do
    render(conn, "index.html")
  end
end

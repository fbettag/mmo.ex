defmodule MMOWeb.PageControllerTest do
  use MMOWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, "/")
    assert html_response(conn, 200) =~ "Welcome to the unbelievable MMO!"
  end
end

defmodule MMOWeb.GameLiveTest do
  use MMOWeb.ConnCase

  import Phoenix.LiveViewTest

  describe "Play the Game" do
    test "joining two players, one killing the other", %{conn: conn} do
      {:ok, view1, _html} = live(conn, Routes.game_path(conn, :play, name: "Player1"))
      {:ok, view2, _html} = live(conn, Routes.game_path(conn, :play, name: "Player2"))

      assert render(view1) =~ "Player2"
      assert render(view2) =~ "Player1"

      assert render_keyup(view1, :keyup, %{key: "Enter"})
      assert render(view2) =~ "DEAD"
      assert render(view1) =~ "ALIVE"
    end

    test "joining three players, one killing all the others", %{conn: conn} do
      {:ok, view1, _html} = live(conn, Routes.game_path(conn, :play, name: "Player1"))
      {:ok, view2, _html} = live(conn, Routes.game_path(conn, :play, name: "Player2"))
      {:ok, view3, _html} = live(conn, Routes.game_path(conn, :play, name: "Player3"))

      assert render(view1) =~ "Player3"
      assert render(view2) =~ "Player1"
      assert render(view3) =~ "Player2"

      assert render_keyup(view1, :keyup, %{key: "Enter"})
      assert render(view2) =~ "DEAD"
      assert render(view3) =~ "DEAD"
      assert render(view1) =~ "ALIVE"
    end

    test "three players, one moving 1 up and killing two", %{conn: conn} do
      {:ok, view1, _html} = live(conn, Routes.game_path(conn, :play, name: "Player1"))
      {:ok, view2, _html} = live(conn, Routes.game_path(conn, :play, name: "Player2"))
      {:ok, view3, _html} = live(conn, Routes.game_path(conn, :play, name: "Player3"))

      assert render(view1) =~ "Player3"
      assert render(view2) =~ "Player1"
      assert render(view3) =~ "Player2"

      assert render_keyup(view1, :keyup, %{key: "ArrowUp"})
      assert render_keyup(view1, :keyup, %{key: "Enter"})
      assert render(view2) =~ "DEAD"
      assert render(view3) =~ "DEAD"
      assert render(view1) =~ "ALIVE"
    end

    test "three players, one moving 2 up and killing none", %{conn: conn} do
      {:ok, view1, _html} = live(conn, Routes.game_path(conn, :play, name: "Player1"))
      {:ok, view2, _html} = live(conn, Routes.game_path(conn, :play, name: "Player2"))
      {:ok, view3, _html} = live(conn, Routes.game_path(conn, :play, name: "Player3"))

      assert render(view1) =~ "Player3"
      assert render(view2) =~ "Player1"
      assert render(view3) =~ "Player2"

      assert render_keyup(view1, :keyup, %{key: "ArrowUp"})
      assert render_keyup(view1, :keyup, %{key: "ArrowUp"})
      assert render_keyup(view1, :keyup, %{key: "Enter"})
      assert render(view2) =~ "ALIVE"
      assert render(view3) =~ "ALIVE"
      assert render(view1) =~ "ALIVE"
    end

    test "three players, one moving 2 up, one moving 1 up and killing one", %{conn: conn} do
      {:ok, view1, _html} = live(conn, Routes.game_path(conn, :play, name: "Player1"))
      {:ok, view2, _html} = live(conn, Routes.game_path(conn, :play, name: "Player2"))
      {:ok, view3, _html} = live(conn, Routes.game_path(conn, :play, name: "Player3"))

      assert render(view1) =~ "Player3"
      assert render(view2) =~ "Player1"
      assert render(view3) =~ "Player2"

      assert render_keyup(view2, :keyup, %{key: "ArrowUp"})

      assert render_keyup(view1, :keyup, %{key: "ArrowUp"})
      assert render_keyup(view1, :keyup, %{key: "ArrowUp"})
      assert render_keyup(view1, :keyup, %{key: "Enter"})
      assert render(view2) =~ "DEAD"
      assert render(view3) =~ "ALIVE"
      assert render(view1) =~ "ALIVE"
    end

    test "two players, firing race condition", %{conn: conn} do
      {:ok, view1, _html} = live(conn, Routes.game_path(conn, :play, name: "Player1"))
      {:ok, view2, _html} = live(conn, Routes.game_path(conn, :play, name: "Player2"))

      assert render(view1) =~ "Player2"
      assert render(view2) =~ "Player1"

      assert render_keyup(view1, :keyup, %{key: "Enter"})
      # this should not kill player1
      assert render_keyup(view2, :keyup, %{key: "Enter"})

      assert render(view2) =~ "DEAD"
      assert render(view1) =~ "ALIVE"
    end

    test "two players, one respawning after 5 seconds", %{conn: conn} do
      {:ok, view1, _html} = live(conn, Routes.game_path(conn, :play, name: "Player1"))
      {:ok, view2, _html} = live(conn, Routes.game_path(conn, :play, name: "Player2"))

      assert render(view1) =~ "Player2"
      assert render(view2) =~ "Player1"

      assert render_keyup(view1, :keyup, %{key: "Enter"})

      assert render(view2) =~ "DEAD"
      assert render(view1) =~ "ALIVE"

      :timer.sleep(:timer.seconds(4))
      assert render(view2) =~ "DEAD"
      :timer.sleep(:timer.seconds(1))
      assert render(view2) =~ "ALIVE"
    end
  end
end

defmodule MMO.Game.HeroTest do
  use MMOWeb.ConnCase
  alias MMO.Game.{Hero, Player}

  describe "Hero GenServer" do
    setup do
      player1 = %Player{name: "Player1"}
      {:ok, pid1} = Hero.start_link(player1)

      player2 = %Player{name: "Player2"}
      {:ok, pid2} = Hero.start_link(player2)

      player3 = %Player{name: "Player3"}
      {:ok, pid3} = Hero.start_link(player3)

      {:ok,
       %{player1: player1, pid1: pid1, player2: player2, pid2: pid2, player3: player3, pid3: pid3}}
    end

    test "joining two players, one killing the other", %{
      player1: player1,
      pid1: pid1,
      player2: player2,
      pid2: pid2
    } do
      assert Hero.move(pid1, "up", {3, 4}) == :ok
      # assert Hero.move(pid2, "down", {5, 4}) == :ok
      assert Hero.fire(pid1) == :ok
      :timer.sleep(:timer.seconds(1))
      assert Hero.get(pid2) == %Player{player2 | alive: false}
      assert Hero.get(pid1) == %Player{player1 | alive: true, position: {3, 4}}
    end

    test "three players, one moving 1 up and killing two",
         %{
           player1: player1,
           pid1: pid1,
           player2: player2,
           pid2: pid2,
           player3: player3,
           pid3: pid3
         } do
      assert Hero.move(pid1, "up", {3, 4}) == :ok
      # assert Hero.move(pid2, "down", {5, 4}) == :ok
      assert Hero.fire(pid1) == :ok
      :timer.sleep(:timer.seconds(1))
      assert Hero.get(pid2) == %Player{player2 | alive: false}
      assert Hero.get(pid3) == %Player{player3 | alive: false}
      assert Hero.get(pid1) == %Player{player1 | alive: true, position: {3, 4}}
    end

    test "three players, one moving 2 up and killing none",
         %{
           player1: player1,
           pid1: pid1,
           player2: player2,
           pid2: pid2,
           player3: player3,
           pid3: pid3
         } do
      assert Hero.move(pid1, "up", {2, 4}) == :ok
      # assert Hero.move(pid2, "down", {5, 4}) == :ok
      assert Hero.fire(pid1) == :ok
      :timer.sleep(:timer.seconds(1))
      assert Hero.get(pid2) == %Player{player2 | alive: true}
      assert Hero.get(pid3) == %Player{player3 | alive: true}
      assert Hero.get(pid1) == %Player{player1 | alive: true, position: {2, 4}}
    end

    test "three players, one moving 2 up, one moving 1 up and killing one",
         %{
           player1: player1,
           pid1: pid1,
           player2: player2,
           pid2: pid2,
           player3: player3,
           pid3: pid3
         } do
      assert Hero.move(pid1, "up", {2, 4}) == :ok
      assert Hero.move(pid2, "up", {3, 4}) == :ok
      assert Hero.fire(pid1) == :ok
      :timer.sleep(:timer.seconds(1))
      assert Hero.get(pid2) == %Player{player2 | alive: false, position: {3, 4}}
      assert Hero.get(pid3) == %Player{player3 | alive: true}
      assert Hero.get(pid1) == %Player{player1 | alive: true, position: {2, 4}}
    end

    # This behavior is to be expected as we are not locking anywhere, but passing messages
    test "two players, firing race condition (killing both)", %{
      player1: player1,
      pid1: pid1,
      player2: player2,
      pid2: pid2
    } do
      assert Hero.fire(pid1) == :ok
      assert Hero.fire(pid2) == :ok
      :timer.sleep(:timer.seconds(1))
      assert Hero.get(pid2) == %Player{player2 | alive: false}
      assert Hero.get(pid1) == %Player{player1 | alive: false}
    end

    test "two players, one respawning after 5 seconds", %{
      player1: player1,
      pid1: pid1,
      player2: player2,
      pid2: pid2
    } do
      assert Hero.fire(pid1) == :ok
      :timer.sleep(:timer.seconds(1))
      assert Hero.get(pid2) == %Player{player2 | alive: false}
      assert Hero.get(pid1) == %Player{player1 | alive: true}

      :timer.sleep(:timer.seconds(3))
      assert Hero.get(pid2) == %Player{player2 | alive: false}
      assert Hero.get(pid1) == %Player{player1 | alive: true}

      :timer.sleep(:timer.seconds(1))
      assert hero = Hero.get(pid2)
      assert hero.alive == true

      assert Hero.get(pid1) == %Player{player1 | alive: true}
    end
  end
end

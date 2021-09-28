defmodule MMO.Game.ServerTest do
  use MMOWeb.ConnCase
  alias MMO.Game.{Server, Hero, Player}

  describe "Server GenServer" do
    setup do
      player = %Player{name: "Gooseking"}
      {:ok, pid} = Hero.start_link(player)
      player = %Player{player | pid: pid}

      {:ok, %{player: player}}
    end

    test "Joining a player", %{player: player} do
      assert Server.join(player) == :ok
    end

    test "Firing with a player", %{player: player} do
      assert Server.fire(player) == :ok
    end

    test "Getting the current board", %{player: player} do
      assert Server.join(player) == :ok
      assert board = Server.get_board()
      assert not Enum.empty?(board.players)
      assert Enum.count(board.players, &(&1.name == player.name)) > 0
    end

    # test "Leaving a player", %{player: player} do
    #  assert Server.join(player) == :ok
    #  assert board = Server.get_board()
    #  assert not Enum.empty?(board.players)
    #  assert Enum.count(board.players, &(&1.name == player.name)) > 0
    #
    #  assert Process.exit(player.pid, :normal) == true
    #  :timer.sleep(:timer.seconds(1))
    #  assert board = Server.get_board()
    #  assert Enum.count(board.players, &(&1.name == player.name)) == 0
    # end
  end
end

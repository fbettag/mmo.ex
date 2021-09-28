defmodule MMO.Game.Server do
  @moduledoc """
  The main Server used to play with a Board and Players.
  """
  use GenServer
  require Logger
  alias Phoenix.PubSub
  alias MMO.Game.{Board, Player}

  def start_link(_) do
    GenServer.start_link(__MODULE__, %Board{}, name: __MODULE__)
  end

  @impl true
  def init(%Board{} = state) do
    {:ok, state}
  end

  def join(%Player{} = player), do: GenServer.cast(__MODULE__, {:join, player})
  def fire(%Player{} = player), do: GenServer.cast(__MODULE__, {:fire, player})
  def update(%Player{} = player), do: GenServer.cast(__MODULE__, {:player, player})
  def get_board, do: GenServer.call(__MODULE__, :get_board)

  @impl true
  def handle_cast({:join, %Player{} = player}, board) do
    Logger.info("[Game] Player \"#{player.name}\" joined (pid #{inspect(player.pid)})")
    # if player.pid != nil, do: Process.monitor(player.pid)

    {:noreply,
     board
     |> add_player(player)
     |> update_clients()}
  end

  @impl true
  def handle_cast({:fire, %Player{}} = msg, board) do
    PubSub.broadcast!(MMO.PubSub, "game", msg)

    {:noreply, board}
  end

  def handle_cast({:player, player}, board) do
    {:noreply,
     board
     |> add_player(player)
     |> update_player(player)
     |> update_clients()}
  end

  @impl true
  def handle_call(:get_board, _from, board), do: {:reply, board, board}

  defp add_player(board, player) do
    players =
      board.players
      |> Enum.filter(&(&1.name != player.name))

    %Board{board | players: players ++ [player]}
  end

  # defp remove_player(board, player) do
  #  players =
  #    board.players
  #    |> Enum.filter(&(&1.pid == player.pid or &1.name == player.name))
  #
  #  %Board{board | players: players}
  # end

  defp update_clients(board) do
    PubSub.broadcast!(MMO.PubSub, "game", {:board, board})
    board
  end

  defp update_player(board, player) do
    PubSub.broadcast!(MMO.PubSub, "game", {:player, player})
    board
  end
end

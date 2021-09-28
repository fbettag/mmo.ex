defmodule MMO.Game.Hero do
  @moduledoc """
  The instance used for holding all state related to a Player
  """
  use GenServer
  require Logger
  alias Phoenix.PubSub
  alias MMO.Game.{Player, Server, Board}

  defp pubsub_name(%Player{} = player), do: {:global, "Hero.#{player.name}"}

  def start_link(%Player{} = player) do
    GenServer.start_link(__MODULE__, player, name: pubsub_name(player))
  end

  @impl true
  def init(%Player{} = player) do
    PubSub.subscribe(MMO.PubSub, "game")
    Server.join(%Player{player | pid: self()})
    {:ok, player}
  end

  def move(hero_pid, direction, to) when is_tuple(to) do
    GenServer.cast(hero_pid, {:move, direction, to})
  end

  def fire(hero_pid), do: GenServer.cast(hero_pid, :fire)
  def get(hero_pid), do: GenServer.call(hero_pid, :get)
  def watch(hero_pid, live_view_pid), do: GenServer.cast(hero_pid, {:monitor, live_view_pid})

  @impl true
  def handle_call(:get, _, player), do: {:reply, player, player}

  @impl true
  def handle_cast({:monitor, live_view_pid}, player) do
    Process.monitor(live_view_pid)
    {:noreply, %Player{player | live_views: player.live_views ++ [live_view_pid]}}
  end

  @impl true
  def handle_cast({:move, direction, {row, col} = to}, player) do
    board = Server.get_board()

    if player.alive == true and not Board.is_wall?(board, row, col) and
         not Board.is_border?(board, row, col) do
      p_row = elem(player.position, 0)
      p_col = elem(player.position, 1)

      Logger.info(
        "[Game] Player \"#{player.name}\" moves #{direction} (#{p_row}, #{p_col} -> #{row}, #{col})"
      )

      player = %Player{player | position: to}
      Server.update(player)
      {:noreply, player}
    else
      {:noreply, player}
    end
  end

  @impl true
  def handle_cast(:fire, player) do
    p_row = elem(player.position, 0)
    p_col = elem(player.position, 1)
    Logger.info("[Game] Player \"#{player.name}\" fired! (#{p_row}, #{p_col})")
    Server.fire(player)
    {:noreply, player}
  end

  @impl true
  def handle_info({:DOWN, _ref, :process, view_pid, reason}, player) do
    live_views = Enum.filter(player.live_views, &(&1 != view_pid))

    Logger.info(
      "[Game] Hero #{inspect(view_pid)} going down: #{inspect(reason)} (#{Enum.count(live_views)} left)"
    )

    if Enum.empty?(live_views), do: Process.exit(self(), :normal)

    {:noreply, %Player{player | live_views: live_views}}
  end

  @impl true
  def handle_info({:fire, killer}, player) do
    if killer.alive and killer.name != player.name and Player.in_range(player, killer.position) do
      p_row = elem(player.position, 0)
      p_col = elem(player.position, 1)

      Logger.info(
        "[Game] Player \"#{player.name}\" killed by #{killer.name} (#{p_row}, #{p_col})"
      )

      Process.send_after(self(), :revive, :timer.seconds(5))
      player = %Player{player | alive: false}
      Server.update(player)
      {:noreply, player}
    else
      {:noreply, player}
    end
  end

  @impl true
  def handle_info(:revive, player) do
    row = Enum.random([1, 3, 5, 7, 8])
    col = Enum.random([1, 2, 4, 5, 7, 8])
    Logger.info("[Game] Player \"#{player.name}\" revived (#{row}, #{col})")

    player = %Player{player | alive: true, position: {row, col}}
    Server.update(player)
    {:noreply, player}
  end

  @impl true
  def handle_info(_, player), do: {:noreply, player}
end

defmodule MMOWeb.GameLive do
  @moduledoc """
  Provides the LiveView component to play the game.
  """
  use Phoenix.LiveView
  alias Phoenix.PubSub
  alias MMO.Game.{Player, Board, Server, Hero}

  @impl true
  def mount(%{"name" => name}, _session, socket) do
    player = %Player{name: name}
    PubSub.subscribe(MMO.PubSub, "game")

    pid =
      case Hero.start_link(player) do
        {:ok, pid} -> pid
        {:error, {:already_started, pid}} -> pid
      end

    Hero.watch(pid, self())
    player = Hero.get(pid)

    {:ok,
     socket
     |> assign(:hero, pid)
     |> assign(:player, player)
     |> assign_board(Server.get_board())}
  end

  defp assign_board(socket, %Board{} = board) do
    cols = Enum.to_list(1..board.width)

    socket
    |> assign(:board, board)
    |> assign(:rows, Enum.to_list(1..board.height))
    |> assign(:cols, cols)
    |> assign(:col_widths, Enum.map_join(cols, " ", fn _ -> "70px" end))
  end

  # inbound move up
  @impl true
  def handle_event("keyup", %{"key" => "ArrowUp"}, socket) do
    with %Player{} = player <- socket.assigns[:player] do
      Hero.move(
        socket.assigns.hero,
        "up",
        {elem(player.position, 0) - 1, elem(player.position, 1)}
      )
    end

    {:noreply, socket}
  end

  # inbound move down
  @impl true
  def handle_event("keyup", %{"key" => "ArrowDown"}, socket) do
    with %Player{} = player <- socket.assigns[:player] do
      Hero.move(
        socket.assigns.hero,
        "down",
        {elem(player.position, 0) + 1, elem(player.position, 1)}
      )
    end

    {:noreply, socket}
  end

  # inbound move left
  @impl true
  def handle_event("keyup", %{"key" => "ArrowLeft"}, socket) do
    with %Player{} = player <- socket.assigns[:player] do
      Hero.move(
        socket.assigns.hero,
        "left",
        {elem(player.position, 0), elem(player.position, 1) - 1}
      )
    end

    {:noreply, socket}
  end

  # inbound move right
  @impl true
  def handle_event("keyup", %{"key" => "ArrowRight"}, socket) do
    with %Player{} = player <- socket.assigns[:player] do
      Hero.move(
        socket.assigns.hero,
        "right",
        {elem(player.position, 0), elem(player.position, 1) + 1}
      )
    end

    {:noreply, socket}
  end

  # inbound firing event
  @impl true
  def handle_event("keyup", %{"key" => "Enter"}, socket) do
    with pid <- socket.assigns[:hero] do
      Hero.fire(pid)
    end

    {:noreply, socket}
  end

  # inbound catchall
  @impl true
  def handle_event("keyup", _, socket) do
    {:noreply, socket}
  end

  # this is just for visualizing the actual firing on the screen
  @impl true
  def handle_info({:fire, player}, socket) do
    Process.send_after(self(), :unfire, :timer.seconds(1))

    {:noreply,
     socket
     |> assign(:fired, player)}
  end

  # this is just for visualizing the actual firing on the screen
  @impl true
  def handle_info(:unfire, socket) do
    {:noreply,
     socket
     |> assign(:fired, nil)}
  end

  # updates the board rendered on the screen
  @impl true
  def handle_info({:board, board}, socket) do
    {:noreply, assign_board(socket, board)}
  end

  # updates your own player
  @impl true
  def handle_info({:player, %Player{} = player}, socket) do
    if socket.assigns[:player] != nil and player.name == socket.assigns.player.name,
      do: {:noreply, assign(socket, :player, player)},
      else: {:noreply, socket}
  end

  @impl true
  def handle_info(_, socket), do: {:noreply, socket}
end

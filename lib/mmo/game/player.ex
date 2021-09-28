defmodule MMO.Game.Player do
  @moduledoc """
  Representation of a Player.
  """
  defstruct name: "Player", alive: true, position: {4, 4}, pid: nil, live_views: []

  # returns a boolean (true) if the given player is on the given row and column
  def is_here?(%__MODULE__{} = player, row, col), do: player.position == {row, col}

  # returns a boolean (true) if the given player is within +1 range of the given row and column
  def in_range(%__MODULE__{} = player, {row, col}) do
    p_row = elem(player.position, 0)
    p_col = elem(player.position, 1)
    p_row >= row - 1 and p_row <= row + 1 and p_col >= col - 1 and p_col <= col + 1
  end

  # returns a boolean (true) if the given player hit the given row and column
  def fired?(%__MODULE__{} = player, row, col) do
    shoot_row = elem(player.position, 0)
    shoot_col = elem(player.position, 1)

    row >= shoot_row - 1 and row <= shoot_row + 1 and col >= shoot_col - 1 and
      col <= shoot_col + 1
  end
end

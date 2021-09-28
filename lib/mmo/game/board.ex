defmodule MMO.Game.Board do
  @moduledoc """
  Representation of a Board where games are being played on.
  """
  defstruct height: 8, width: 8, walls: [{2, 3}, {4, 6}, {6, 3}], players: []

  # returns a boolean (true) if the given row and column is a wall-piece
  def is_wall?(%__MODULE__{} = board, row, col),
    do: Enum.member?(board.walls, {row, col})

  # returns a boolean (true) if the given row and column are outside the grid
  def is_border?(%__MODULE__{} = board, row, col),
    do: row < 1 or row > board.height or col < 1 or col > board.width
end

# frozen_string_literal: true

require_relative 'piece'
require_relative 'step_piece'

# Knight logic
class Knight < Piece
  include StepPiece

  def symbol
    '♞'.color(color)
  end

  # #moves in module StepPiece

  def move_set
    [[-2, 1], [-1, 2], [1, 2], [2, 1], [2, -1], [1, -2], [-1, -2], [-2, -1]]
  end
end

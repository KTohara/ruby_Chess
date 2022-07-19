# frozen_string_literal: true

require_relative 'piece'
require_relative 'step_piece'

# King logic
class King < Piece
  include StepPiece

  def symbol
    '♚'.color(color)
  end

  private

  def move_set
    [[-1, -1], [-1, 0], [-1, 1], [0, 1], [1, 1], [1, 0], [1, -1], [0, -1]]
  end
end

# frozen_string_literal: true

require_relative 'piece'
require_relative 'sliding'

# Queen logic
class Queen < Piece
  include Sliding

  def symbol
    color == :white ? '♕' : '♛'
  end

  private

  def move_set
    HORIZONTAL_AND_VERTICAL_DIRS + DIAGONAL_DIRS
  end
end

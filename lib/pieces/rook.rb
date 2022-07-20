# frozen_string_literal: true

require_relative 'piece'
require_relative 'slide_piece'

# Rook logic
class Rook < Piece
  include SlidePiece

  def symbol
    '♜'.color(color)
  end

  private

  def move_set
    horizontal_and_vertical_dir
  end
end

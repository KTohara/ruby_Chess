# frozen_string_literal: true

require_relative 'piece'
require_relative 'slide_piece'

# Bishop logic
class Bishop < Piece
  include SlidePiece

  def symbol
    '♝'.color(color)
  end

  private

  def move_set
    diagonal_dir
  end
end

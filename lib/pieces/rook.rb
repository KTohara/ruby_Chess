# frozen_string_literal: true

require_relative 'piece'
require_relative 'sliding'

# Rook logic
class Rook < Piece
  include Sliding

  def symbol
    '♜'.color(color)
  end

  private

  def move_set
    horizontal_and_vertical_dir
  end
end

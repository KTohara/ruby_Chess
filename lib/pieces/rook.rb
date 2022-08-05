# frozen_string_literal: true

require_relative 'piece'
require_relative 'sliding'

# Rook logic
class Rook < Piece
  include Sliding

  def symbol
    '♜'
  end

  private

  def move_set
    HORIZONTAL_AND_VERTICAL_DIRS
  end
end

# frozen_string_literal: true

require_relative 'piece'

# Rook logic
class Rook < Piece
  def symbol
    '♜'.color(color)
  end
end

# frozen_string_literal: true

require_relative 'piece'

# Pawn logic
class Pawn < Piece
  def symbol
    '♟'.color(color)
  end
end

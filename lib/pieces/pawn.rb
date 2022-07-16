# frozen_string_literal: true

require_relative 'piece'

class Pawn < Piece
  def symbol
    '♟'.color(color)
  end
end

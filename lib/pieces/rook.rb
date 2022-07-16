# frozen_string_literal: true

require_relative 'piece'

class Rook < Piece
  def symbol
    '♜'.color(color)
  end
end

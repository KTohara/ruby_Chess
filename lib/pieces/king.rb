# frozen_string_literal: true

require_relative 'piece'

class King < Piece
  def symbol
    '♚'.color(color)
  end
end

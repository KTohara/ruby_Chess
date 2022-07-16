# frozen_string_literal: true

require_relative 'piece'

class Queen < Piece
  def symbol
    '♛'.color(color)
  end
end

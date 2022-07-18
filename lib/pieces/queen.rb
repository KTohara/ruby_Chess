# frozen_string_literal: true

require_relative 'piece'

# Queen logic
class Queen < Piece
  def symbol
    '♛'.color(color)
  end
end

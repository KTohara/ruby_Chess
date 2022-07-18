# frozen_string_literal: true

require_relative 'piece'

# Bishop logic
class Bishop < Piece
  def symbol
    '♝'.color(color)
  end
end

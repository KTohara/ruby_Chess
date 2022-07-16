# frozen_string_literal: true

require_relative 'piece'

class Bishop < Piece
  def symbol
    '♝'.color(color)
  end
end

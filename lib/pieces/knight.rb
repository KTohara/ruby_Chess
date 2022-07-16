# frozen_string_literal: true

require_relative 'piece'

class Knight < Piece
  def symbol
    '♞'.color(color)
  end
end

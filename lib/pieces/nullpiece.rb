# frozen_string_literal: true

require_relative 'piece'

class NullPiece < Piece
  def symbol
    ' '
  end
end

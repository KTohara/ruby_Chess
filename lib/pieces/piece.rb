# frozen_string_literal: true

require_relative '../color'

# Chess piece superclass
class Piece
  attr_reader :color, :board, :pos

  def initialize(color, board, pos)
    @color = color
    @board = board
    @pos = pos
  end

  def to_s
    " #{symbol} "
  end

  def empty?
    false
  end

  # def symbol
  #   # subclass placeholder method for unicode chars
  # end

  def moves
    []
  end

  def valid_moves
    board.grid
  end
end

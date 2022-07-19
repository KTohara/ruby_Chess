# frozen_string_literal: true

require_relative '../color'

# Chess piece superclass
class Piece
  attr_reader :color, :board
  attr_accessor :pos

  def initialize(color, pos)
    @color = color
    @pos = pos
    @moves = []
    @captures = []
    @moved = false
  end

  def to_s
    " #{symbol} "
  end

  def empty?
    false
  end

  private

  def valid_location?(pos)
    pos.all? { |coord| coord.between?(0, 7) }
  end
  require 'byebug'
  def enemy?(piece)
    return false if piece.color == :none

    enemy_color = color == :white ? :black : :white
    piece.color == enemy_color
  end

  def empty_location?(coord)
    coord.empty?
  end

  def symbol
    # subclass placeholder method for unicode chars
  end
end

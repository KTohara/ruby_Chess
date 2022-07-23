# frozen_string_literal: true

require_relative '../colors'

# Chess piece superclass
class Piece
  attr_reader :color, :board, :moved, :row, :col
  attr_accessor :pos

  def initialize(color, pos)
    @color = color
    @pos = pos
    @row = pos.first
    @col = pos.last
    @moves = []
    @captures = []
    @moved = false
  end

  def to_s
    "░#{symbol}░"
  end

  def empty?
    false
  end

  def update(pos, grid)
    update_en_passant(grid) if instance_of?(Pawn)
    update_moved
    update_position(pos)
  end

  private

  def valid_location?(pos)
    pos.all? { |coord| coord.between?(0, 7) }
  end

  def enemy?(piece)
    return false if piece.color == :none

    enemy_color = color == :white ? :black : :white
    piece.color == enemy_color
  end

  def ally?(piece)
    piece.color == color
  end

  def empty_location?(piece)
    piece.empty?
  end

  def symbol
    # subclass placeholder method for unicode chars
  end

  def update_moved
    @moved = true
  end

  def update_position(pos)
    @pos = pos
    @row = pos.first
    @col = pos.last
  end
end

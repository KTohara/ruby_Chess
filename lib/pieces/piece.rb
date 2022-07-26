# frozen_string_literal: true

require_relative '../colors'

# Chess piece superclass
class Piece
  attr_reader :color, :board, :moved, :row, :col, :moves
  attr_accessor :pos

  def initialize(color, pos)
    @color = color
    @pos = pos
    @row = pos.first
    @col = pos.last
    @moves = Hash.new { |h, k| h[k] = [] }
    @moved = false
  end

  def to_s
    "░#{symbol}░"
  end

  def empty?
    false
  end

  def update(end_pos, grid)
    update_position(end_pos)
    update_en_passant(grid) if instance_of?(Pawn)
    update_moved
  end

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

  private

  def update_moved
    @moved = true
  end

  def update_position(pos)
    @pos = pos
    @row = pos.first
    @col = pos.last
  end

  def reset_moves
    @moves = Hash.new { |h, k| h[k] = [] }
  end
end

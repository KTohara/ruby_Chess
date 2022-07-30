# frozen_string_literal: true

require_relative '../colors'

# Chess piece superclass
class Piece
  attr_reader :color, :row, :col, :moves, :moved
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

  def symbol
    # subclass attribute
  end

  def update_moves
    # subclass / module method
  end

  def list_all_moves
    moves.values.flatten(1).compact
    # moves.values.flatten(1).compact.reject(&:empty?)
  end

  def list_all_captures
    moves[:captures] + moves[:en_passant]
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

  def add_moves(new_pos, piece)
    if piece.empty?
      moves[:moves] << new_pos
    elsif enemy?(piece)
      moves[:captures] << new_pos
    end
  end

  def add_move(move_pos)
    moves[:moves] << move_pos
  end

  def add_capture(capture_pos)
    moves[:captures] << capture_pos
  end
end

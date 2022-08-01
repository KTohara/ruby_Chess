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

  # default boolean whether piece/postion is occupied
  def empty?
    false
  end

  def symbol
    # subclass attribute
  end

  def update_moves
    # method for piece subclasses / stepping/sliding module
  end

  # updates a piece's position, toggles en passant (if pawn), toggles moved
  def update(end_pos, grid)
    update_position(end_pos)
    update_en_passant(grid) if instance_of?(Pawn) # this method order cannot be changed
    update_moved
  end

  # boolean whether position is within bounds of the board
  def valid_location?(pos)
    pos.all? { |coord| coord.between?(0, 7) }
  end

  # boolean if a piece is an enemy
  def enemy?(piece)
    return false if piece.color == :none

    enemy_color = color == :white ? :black : :white
    piece.color == enemy_color
  end

  # returns array of a piece's moves
  def list_all_moves
    moves.values.flatten(1).compact
  end

  # returns array of a piece's captures
  def list_all_captures
    moves[:captures] + moves[:en_passant]
  end

  private

  # toggles once a piece has been moved
  def update_moved
    @moved = true
  end

  # updates position in relation to the board after a piece has been moved
  def update_position(position)
    @pos = position
    @row = position.first
    @col = position.last
  end

  # resets all moves (called after each turn)
  def reset_moves
    @moves = Hash.new { |h, k| h[k] = [] }
  end

  # adds a move or capture to the move hash
  def add_moves(new_pos, piece)
    if piece.empty?
      add_move(new_pos)
    elsif enemy?(piece)
      add_capture(new_pos)
    end
  end

  # adds a move to move hash
  def add_move(move_pos)
    moves[:moves] << move_pos
  end

  # adds a capture to move hash
  def add_capture(capture_pos)
    moves[:captures] << capture_pos
  end
end

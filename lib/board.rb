# frozen_string_literal: true

require_relative 'pieces'
require_relative 'special_moves'
require_relative 'utility/messages'

require 'byebug'

# Board basic logic
class Board
  include SpecialMoves
  include Messages

  attr_reader :grid, :last_move

  def initialize
    @grid = Array.new(8) { Array.new(8, NullPiece.new) }
    @last_move = nil
    create_board
  end

  # returns element on grid by position
  def [](pos)
    raise PositionError unless valid_pos?(pos)

    row, col = pos
    @grid[row][col]
  end

  # changes element on grid to a given piece, based on grid position
  def []=(pos, piece)
    raise PositionError unless valid_pos?(pos)

    row, col = pos
    @grid[row][col] = piece
  end

  # validates starting position: position empty? piece is yours?
  def validate_start_pos(turn_color, start_pos)
    piece = self[start_pos]

    raise SquareError if empty?(start_pos)
    raise OpponentError if piece.color != turn_color
  end

  # validates ending position: piece can move to position? piece does not cause check?
  def validate_end_pos(start_pos, end_pos, turn_color)
    start_piece = self[start_pos]
    moves = start_piece.list_all_moves

    raise MoveError unless moves.include?(end_pos)
    raise CheckError if move_causes_check?(turn_color, start_pos, end_pos)
  end

  # moves a piece to new location, places null piece in old location, updates last move
  def move_piece(start_pos, end_pos)
    piece = self[start_pos]
    self[end_pos] = piece
    self[start_pos] = NullPiece.new
    piece.update(end_pos, grid)
    @last_move = end_pos
  end

  # position is in bounds of grid
  def valid_pos?(pos)
    pos.all? { |axis| axis.between?(0, 7) }
  end

  # position is empty?
  def empty?(pos)
    self[pos].empty?
  end

  # check returns true if any enemy pieces have capture moves that include the king's position
  def check?(turn_color)
    update_all_moves
    enemy_pieces(turn_color).any? do |piece|
      piece.list_all_captures.include?(king_pos(turn_color))
    end
  end

  # checkmate returns true if player has no pieces with moves that do not cause a check
  def checkmate?(turn_color)
    return false unless check?(turn_color)

    ally_pieces(turn_color).none? do |piece|
      moves = piece.list_all_moves
      moves.any? { |move| !move_causes_check?(turn_color, piece.pos, move) }
    end
  end

  private

  # fills the board with its respective colored pieces
  def create_board
    %i[white black].each do |color|
      fill_back_row(color)
      fill_pawns_row(color)
    end
  end

  # fills back row with respective colored pieces
  def fill_back_row(color)
    back_pieces = [Rook, Knight, Bishop, Queen, King, Bishop, Knight, Rook]

    row = color == :black ? 0 : 7
    back_pieces.each_with_index do |piece, col|
      pos = row, col
      self[pos] = piece.new(color, pos)
    end
  end

  # fills front row with respective colored pawns
  def fill_pawns_row(color)
    row = color == :black ? 1 : 6
    8.times do |col|
      pos = row, col
      self[pos] = Pawn.new(color, pos)
    end
  end
end

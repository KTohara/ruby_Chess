# frozen_string_literal: true

require_relative 'pieces'
require_relative 'special_moves'
require 'byebug'
# Board basic logic
class Board
  include SpecialMoves

  attr_reader :grid, :last_move

  def initialize
    @grid = Array.new(8) { Array.new(8, NullPiece.new) }
    @last_move = nil
    create_board
  end

  def [](pos)
    raise 'Invalid position' unless valid_pos?(pos)

    row, col = pos
    @grid[row][col]
  end

  def []=(pos, piece)
    raise 'Invalid position' unless valid_pos?(pos)

    row, col = pos
    @grid[row][col] = piece
  end

  def validate_start_pos(turn_color, start_pos)
    piece = self[start_pos]
    raise 'Square is empty' if empty?(start_pos)
    raise 'You must move your own pieces' if piece.color != turn_color
  end

  def validate_end_pos(start_pos, end_pos, turn_color)
    start_piece = self[start_pos]
    moves = start_piece.list_all_moves

    raise 'Invalid move for this piece' unless moves.include?(end_pos)
    raise 'Move puts king in check' if move_causes_check?(turn_color, start_pos, end_pos)
  end

  def move_piece(start_pos, end_pos)
    piece = self[start_pos]
    self[end_pos] = piece
    en_passant_move(piece, end_pos) if piece.moves[:en_passant].include?(end_pos)
    castling_move(end_pos) if piece.moves[:castling].include?(end_pos)
    promote_pawn if piece.pawn_promotion?(end_pos)
    self[start_pos] = NullPiece.new
    piece.update(end_pos, grid)
    @last_move = end_pos
    nil
  end

  def valid_pos?(pos)
    pos.all? { |axis| axis.between?(0, 7) }
  end

  def empty?(pos)
    self[pos].empty?
  end

  def check?(turn_color)
    update_all_moves
    enemy_pieces(turn_color).any? do |piece|
      piece.list_all_captures.include?(king_pos(turn_color))
    end
  end

  def checkmate?(turn_color)
    return false unless check?(turn_color)

    ally_pieces(turn_color).none? do |piece|
      moves = piece.list_all_moves
      moves.any? { |move| !move_causes_check?(turn_color, piece.pos, move) }
    end
  end

  private

  attr_reader :null_piece

  def create_board
    %i[white black].each do |color|
      fill_back_row(color)
      fill_pawns_row(color)
    end
  end

  def fill_back_row(color)
    back_pieces = [Rook, Knight, Bishop, Queen, King, Bishop, Knight, Rook]

    row = color == :black ? 0 : 7
    back_pieces.each_with_index do |piece, col|
      pos = row, col
      self[pos] = piece.new(color, pos)
    end
  end

  def fill_pawns_row(color)
    row = color == :black ? 1 : 6
    8.times do |col|
      pos = row, col
      self[pos] = Pawn.new(color, pos)
    end
  end
end

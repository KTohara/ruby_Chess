# frozen_string_literal: true

require_relative 'pieces'
require_relative 'special_moves'
require_relative 'utility/messages'

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
    piece = self[start_pos]
    moves = piece.list_all_moves

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

  def enemy_king(turn_color)
    enemy_pieces(turn_color).find { |piece| piece.instance_of?(King) }
  end

  # finds the position of the given color's king
  def king_pos(turn_color)
    ally_pieces(turn_color).find { |piece| piece.instance_of?(King) }.pos
  end

  # check returns true if any enemy pieces have capture moves that include the king's position
  def check?(turn_color)
    update_all_moves
    enemy_pieces(turn_color).any? do |piece|
      piece.list_all_captures.include?(king_pos(turn_color))
    end
  end

  # calls stalemate only if player is in check
  def checkmate?(turn_color)
    return false unless check?(turn_color)

    stalemate?(turn_color)
  end

  # returns true if all of a player's pieces cause their own king to be in check
  def stalemate?(turn_color)
    ally_pieces(turn_color).all? do |piece|
      moves = piece.list_all_moves
      moves.all? { |move| move_causes_check?(turn_color, piece.pos, move) }
    end
  end

  # needs tests
  def insufficient_material?
    only_kings_bishops? || only_kings_knights? || only_kings?
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

  # updates moves for all pieces on the board
  def update_all_moves
    pieces.each { |piece| piece.update_moves(grid, last_move) }
  end

  # tests a move to see if it causes a king to be in check
  def move_causes_check?(turn_color, start_pos, end_pos)
    undo_piece = self[end_pos]
    test_move(start_pos, end_pos)
    check_status = check?(turn_color)
    undo_move(end_pos, start_pos, undo_piece)
    update_all_moves
    check_status
  end

  # moves a piece, and places a null piece in it's place
  def test_move(start_pos, end_pos)
    piece = self[start_pos]
    self[end_pos] = piece
    piece.pos = end_pos
    self[start_pos] = NullPiece.new
  end

  # moves the piece back to it's starting position, and places the original piece back in it's place
  def undo_move(end_pos, start_pos, undo_piece)
    piece = self[end_pos]
    self[start_pos] = piece
    piece.pos = start_pos
    self[end_pos] = undo_piece
  end
end

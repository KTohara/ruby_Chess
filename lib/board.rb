# frozen_string_literal: true

require_relative 'pieces'

# Board logic
class Board
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

  # test
  def validate_start_pos(turn_color, start_pos)
    piece = self[start_pos]
    raise 'Square is empty' if empty?(start_pos)
    raise 'You must move your own pieces' if piece.color != turn_color

    nil
  end

  # test
  def validate_end_pos(start_pos, end_pos)
    start_piece = self[start_pos]
    moves = start_piece.valid_moves(grid, last_move)
    raise 'Invalid move for this piece' unless moves.include?(end_pos)

    nil
  end

  # test
  def move_piece!(start_pos, end_pos)
    piece = self[start_pos]
    self[end_pos] = piece
    if piece.moves[:en_passant].include?(end_pos)
      self[piece.en_passant_enemy_pos(end_pos)] = NullPiece.new
    end
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

  def checkmate?(player); end

  def check?; end

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

# b = Board.new
# b.move_piece(:black, [0, 3], [5, 4])
# # b.move_piece(:black, [0, 1], [5, 3])
# queen = b[[5, 4]]
# pawn = b[[1, 2]]
# puts b
# p queen.valid_moves(b)
# p pawn.jumps(b)
# puts b

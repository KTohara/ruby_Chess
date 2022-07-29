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

  def validate_start_pos(turn_color, start_pos)
    piece = self[start_pos]
    raise 'Square is empty' if empty?(start_pos)
    raise 'You must move your own pieces' if piece.color != turn_color

    nil
  end

  def validate_end_pos(start_pos, end_pos, turn_color)
    start_piece = self[start_pos]
    moves = start_piece.list_all_moves
    raise 'Invalid move for this piece' unless moves.include?(end_pos)
    raise 'Move puts king in check' if check?(turn_color, king)
    nil
  end

  def move_piece(start_pos, end_pos)
    piece = self[start_pos]
    self[end_pos] = piece
    en_passant_move(piece, end_pos) if piece.moves[:en_passant].include?(end_pos)
    castling_move(end_pos) if piece.moves[:castling].include?(end_pos)
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

  def en_passant_move(piece, end_pos)
    self[piece.en_passant_enemy_pos(end_pos)] = NullPiece.new
  end

  def castling_move(end_pos)
    row, col = end_pos
    old_rook_pos, new_rook_pos = col == 6 ? king_castle(row) : queen_castle(row)
    rook_piece = self[old_rook_pos]
    self[new_rook_pos] = rook_piece
    self[old_rook_pos] = NullPiece.new
  end

  def checkmate?(player); end

  def check?(turn_color, king = nil)
    king ||= pieces.find { |p| p.instance_of?(King) && p.color == turn_color }
    pieces.each { |piece| piece.valid_moves(grid, last_move) }
    opponent_pieces = pieces.reject { |piece| piece.color == turn_color || piece.pos == king.pos }

    opponent_pieces.any? { |piece| piece.list_all_moves.include?(king.pos) }
    # fix king.pos - needs to be actual moved end position
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

  def king_castle(row)
    old_rook_col = 7
    new_rook_col = 5
    [[row, old_rook_col], [row, new_rook_col]]
  end

  def queen_castle(row)
    old_rook_col = 0
    new_rook_col = 3
    [[row, old_rook_col], [row, new_rook_col]]
  end

  def pieces
    grid.flatten.reject(&:empty?)
  end

  def find_king(color)
    pieces.find { |piece| piece.instance_of?(King) && piece.color == turn_color }
  end
end

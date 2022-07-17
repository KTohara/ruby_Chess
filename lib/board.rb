# frozen_string_literal: true

require_relative 'pieces'

# Board logic
class Board
  attr_reader :grid

  def initialize
    @null_piece = NullPiece.instance
    @grid = Array.new(8) { Array.new(8, null_piece) }
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

  def move_piece(color, start_pos, end_pos)
    raise 'Square is empty' if empty?(start_pos)

    picked_piece = self[start_pos]
    ending_cell = self[end_pos]

    if picked_piece.color != color
      raise 'You must move your own pieces'
    elsif !picked_piece.valid_moves.include?(end_pos)
      raise 'Invalid move for this piece'
    end

    self[start_pos] = null_piece
    self[end_pos] = picked_piece
  end

  def valid_pos?(pos)
    pos.all? { |axis| axis.between?(0, 7) }
  end

  def empty?(pos)
    self[pos].empty?
  end

  # def add_piece(piece, pos); end

  def checkmate?; end

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
      self[pos] = piece.new(color, self, pos)
    end
  end

  def fill_pawns_row(color)
    row = color == :black ? 1 : 6
    8.times do |col|
      pos = row, col
      self[pos] = Pawn.new(color, self, pos)
    end
  end

  # temp render method
  def to_s
    render = grid.map { |row| row.map(&:to_s) }
    render.each { |row| puts row.join }
  end
end

b = Board.new
puts b
p b.empty?([3, 0])
p b.move_piece(:white, [7, 3], [3, 3])
puts b
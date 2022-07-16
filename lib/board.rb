# frozen_string_literal: true

require_relative 'pieces'

# Board logic
class Board
  attr_reader :grid

  def initialize
    @null_piece = nil
    @grid = Array.new(8) { Array.new(8, nil) } # nil - placeholder for nullpiece
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

  def move_piece(color, start_pos, end_pos); end

  def valid_pos?(pos)
    pos.all? { |axis| axis.between?(0, 7) }
  end

  def empty?(pos); end

  def add_piece(piece, pos); end

  def checkmate?; end

  def check?; end

  private

  def create_board
    %i[white black].each do |color|
      fill_back_row(color)
      fill_pawns_row(color)
    end
  end

  def fill_back_row(color)
    back_pieces = [Rook, Knight, Bishop, Queen, King, Bishop, Knight, Rook] # placeholder piece for now

    row = color == :black ? 0 : 7
    back_pieces.each_with_index do |piece, col|
      pos = row, col
      self[pos] = piece.new(color)
    end
  end

  def fill_pawns_row(color)
    row = color == :black ? 1 : 6
    (0..7).each do |col|
      pos = row, col
      self[pos] = Pawn.new(color)
    end
  end

  # temp render method
  def to_s
    render = grid.map { |row| row.map(&:to_s) }
    render.each { |row| puts row.join }
  end
end

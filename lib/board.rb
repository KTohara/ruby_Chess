# frozen_string_literal: true

# Board logic
class Board
  attr_reader :rows

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

  def empty?(pos)

  end

  # def add_piece(piece, pos)

  # end

  def create_board
    %i[white black].each do |color|
      fill_back_row(color)
      fill_pawns_row(color)
    end
  end

  def fill_back_row(color)
      
  end

  def fill_pawns_row(color)
  
  end
end

# frozen_string_literal: true

require_relative 'piece'
require_relative 'stepping'

# King logic
class King < Piece
  include Stepping

  def symbol
    color == :white ? '♔' : '♚'
  end

  def update_moves(grid, _last_move)
    super
    king_side_castling(grid)
    queen_side_castling(grid)
  end

  private

  def move_set
    [[-1, -1], [-1, 0], [-1, 1], [0, 1], [1, 1], [1, 0], [1, -1], [0, -1]]
  end

  def king_side_castling(grid)
    rook_col = 7
    king_side = grid[row][rook_col]
    return if moved || king_side.empty? || king_side.moved

    king_side_pos = [row, col + 2]
    moves[:castling] << king_side_pos if rook_path_clear?(grid, rook_col)
  end

  def queen_side_castling(grid)
    rook_col = 0
    queen_side = grid[row][rook_col]
    return if moved || queen_side.empty? || queen_side.moved

    queen_side_pos = [row, col - 2]
    moves[:castling] << queen_side_pos if rook_path_clear?(grid, rook_col)
  end

  def rook_path_clear?(grid, rook_col)
    if rook_col.zero?
      (1...col).all? { |square| grid[row][square].empty? }
    else
      (col + 1...7).all? { |square| grid[row][square].empty? }
    end
  end
end

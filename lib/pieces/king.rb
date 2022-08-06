# frozen_string_literal: true

require_relative 'piece'
require_relative 'stepping'

# King logic
class King < Piece
  include Stepping

  attr_accessor :castling

  def initialize(color, pos)
    @castling = false
    super
  end

  def symbol
    color == :white ? '♔' : '♚'
  end

  # updates @moves hash
  def update_moves(grid, _last_move)
    super
    king_side_castling(grid) if castling
    queen_side_castling(grid) if castling
  end

  def update_castling(check)
    @castling = !check
  end

  # determines if the back row between king and rook are empty
  def rook_path_clear?(grid, rook_col)
    if rook_col.zero?
      (1...col).all? { |square| grid[row][square].empty? }
    else
      (col + 1...7).all? { |square| grid[row][square].empty? }
    end
  end

  private

  # directions king can move
  def move_set
    [[-1, -1], [-1, 0], [-1, 1], [0, 1], [1, 1], [1, 0], [1, -1], [0, -1]]
  end

  # adds king side castling position if all conditions are met
  def king_side_castling(grid)
    rook_col = 7
    king_side_rook = grid[row][rook_col]
    return unless castling_conditions?(king_side_rook)

    king_side_pos = [row, col + 2]
    add_castling(king_side_pos) if rook_path_clear?(grid, rook_col)
  end

  # adds queen side castling position if all conditions are met
  def queen_side_castling(grid)
    rook_col = 0
    queen_side_rook = grid[row][rook_col]
    return unless castling_conditions?(queen_side_rook)

    queen_side_pos = [row, col - 2]
    add_castling(queen_side_pos) if rook_path_clear?(grid, rook_col)
  end

  def castling_conditions?(piece)
    return false if piece.empty?

    piece.instance_of?(Rook) || !piece.moved || !moved
  end

  # adds the castling move to the move hash
  def add_castling(castling_pos)
    moves[:castling] << castling_pos
  end
end

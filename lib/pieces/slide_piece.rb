# frozen_string_literal: true

# move logic for rook/bishop/queen
module SlidePiece
  HORIZONTAL_AND_VERTICAL_DIRS = [[-1, 0], [0, -1], [0, 1], [1, 0]].freeze
  DIAGONAL_DIRS = [[-1, -1], [-1, 1], [1, -1], [1, 1]].freeze

  def horizontal_and_vertical_dir
    HORIZONTAL_AND_VERTICAL_DIRS
  end

  def diagonal_dir
    DIAGONAL_DIRS
  end

  def valid_moves(board)
    @moves = move_set.each_with_object([]) do |set_pos, possible_moves|
      row, col = pos
      sx, sy = set_pos
      new_pos = [row + sx, col + sy]
      directional_moves = check_move_dir(new_pos, set_pos, board.grid)
      directional_moves.empty? ? next : possible_moves.concat(directional_moves)
    end
  end

  private

  def check_move_dir(new_pos, set_pos, grid, moves = [])
    row, col = new_pos
    sx, sy = set_pos
    while valid_location?([row, col])
      coord = grid[row][col]
      moves << [row, col] if enemy?(coord) || empty_location?(coord)
      break if ally?(coord) || enemy?(coord)

      row += sx
      col += sy
    end
    moves
    # moves.each { |el| grid[el[0]][el[1]] = ' m ' }
  end
end

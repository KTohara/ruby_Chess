# frozen_string_literal: true

# move logic for rook/bishop/queen
module Sliding
  HORIZONTAL_AND_VERTICAL_DIRS = [[-1, 0], [0, -1], [0, 1], [1, 0]].freeze
  DIAGONAL_DIRS = [[-1, -1], [-1, 1], [1, -1], [1, 1]].freeze

  def valid_moves(grid, _last_move)
    reset_moves

    move_set.each do |set_pos|
      sx, sy = set_pos
      new_pos = [row + sx, col + sy]
      check_move_dir(new_pos, set_pos, grid)
    end
    moves.values.flatten(1).compact.reject(&:empty?)
  end

  private

  def horizontal_and_vertical_dir
    HORIZONTAL_AND_VERTICAL_DIRS
  end

  def diagonal_dir
    DIAGONAL_DIRS
  end

  def check_move_dir(new_pos, set_pos, grid)
    nx, ny = new_pos
    sx, sy = set_pos
    while valid_location?([nx, ny])
      coord = grid[nx][ny]
      moves[:moves] << [nx, ny] if empty_location?(coord)
      moves[:captures] << [nx, ny] if enemy?(coord)
      break if ally?(coord) || enemy?(coord)

      nx += sx
      ny += sy
    end
  end
end

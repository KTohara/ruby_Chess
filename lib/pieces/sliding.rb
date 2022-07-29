# frozen_string_literal: true

# move logic for rook/bishop/queen
module Sliding
  HORIZONTAL_AND_VERTICAL_DIRS = [[-1, 0], [0, -1], [0, 1], [1, 0]].freeze
  DIAGONAL_DIRS = [[-1, -1], [-1, 1], [1, -1], [1, 1]].freeze

  def valid_moves(grid, _last_move)
    reset_moves

    move_set.each do |dir_pos|
      dx, dy = dir_pos
      new_pos = [row + dx, col + dy]
      populate_sliding_moves(new_pos, dir_pos, grid)
    end
    # moves.values.flatten(1).compact.reject(&:empty?)
  end

  private

  def horizontal_and_vertical_dir
    HORIZONTAL_AND_VERTICAL_DIRS
  end

  def diagonal_dir
    DIAGONAL_DIRS
  end

  def populate_sliding_moves(new_pos, dir_pos, grid)
    nx, ny = new_pos
    dx, dy = dir_pos
    while valid_location?([nx, ny])
      coord = grid[nx][ny]
      moves[:moves] << [nx, ny] if coord.empty?
      moves[:captures] << [nx, ny] if enemy?(coord)
      break if ally?(coord) || enemy?(coord)

      nx += dx
      ny += dy
    end
  end
end

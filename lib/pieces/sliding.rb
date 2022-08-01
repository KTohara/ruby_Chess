# frozen_string_literal: true

# move logic for rook/bishop/queen
module Sliding
  HORIZONTAL_AND_VERTICAL_DIRS = [[-1, 0], [0, -1], [0, 1], [1, 0]].freeze
  DIAGONAL_DIRS = [[-1, -1], [-1, 1], [1, -1], [1, 1]].freeze

  # updates new position based on direction
  # increments by one vertical / horizontal / diagonal cell
  # adds move to move hash if empty and within bounds of the board
  def update_moves(grid, _last_move)
    reset_moves

    move_set.each do |dir_pos|
      dx, dy = dir_pos
      new_pos = [row + dx, col + dy]
      populate_sliding_moves(new_pos, dir_pos, grid)
    end
  end

  private

  # helper method for #update_moves
  def populate_sliding_moves(new_pos, dir_pos, grid)
    dx, dy = dir_pos
    while valid_location?(new_pos)
      piece = grid[new_pos[0]][new_pos[1]]
      add_moves(new_pos, piece)
      break unless piece.empty?

      new_pos = [new_pos[0] + dx, new_pos[1] + dy]
    end
  end
end

# frozen_string_literal: true

# Move logic for king/knight
module Stepping
  def update_moves(grid, _last_move)
    reset_moves
    populate_stepping_moves(grid)
    # moves.values.flatten(1).compact.reject(&:empty?)
  end

  private

  def populate_stepping_moves(grid)
    move_set.each do |sx, sy|
      sx += row
      sy += col
      new_pos = [sx, sy]
      next unless valid_location?(new_pos)

      piece = grid[sx][sy]
      add_moves(new_pos, piece)
    end
  end
end

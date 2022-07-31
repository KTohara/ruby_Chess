# frozen_string_literal: true

# Move logic for king/knight
module Stepping
  # iterates through each piece's given move set
  # adds move to move list if position is within bounds of the board
  def update_moves(grid, _last_move)
    reset_moves
    populate_stepping_moves(grid)
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

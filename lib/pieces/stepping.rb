# frozen_string_literal: true

# Move logic for king/knight
module Stepping
  def valid_moves(grid, _last_move)
    reset_moves

    move_set.each do |sx, sy|
      px = row + sx
      py = col + sy
      next unless valid_location?([px, py])

      coord = grid[px][py]
      moves[:moves] << [px, py] if empty_location?(coord)
      moves[:captures] << [px, py] if enemy?(coord)
    end
    moves.values.flatten(1).compact.reject(&:empty?)
  end
end

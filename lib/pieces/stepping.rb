# frozen_string_literal: true

# Move logic for king/knight
module Stepping
  def valid_moves(board)
    @moves = move_set.each_with_object([]) do |(sx, sy), possible_moves|
      px = row + sx
      py = col + sy
      next unless valid_location?([px, py])

      coord = board.grid[px][py]
      possible_moves << [px, py] if empty_location?(coord) || enemy?(coord)
    end
  end
end

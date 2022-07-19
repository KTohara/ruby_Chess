# frozen_string_literal: true

# Move logic for king/knight
module StepPiece
  def valid_moves(board)
    @moves = move_set.each_with_object([]) do |(sx, sy), possible_moves|
      row = pos.first + sx
      col = pos.last + sy
      next unless valid_location?([row, col])

      coord = board.grid[row][col]
      possible_moves << [row, col] if empty_location?(coord)
    end
  end

  def valid_captures(board)
    @captures = move_set.each_with_object([]) do |(sx, sy), possible_moves|
      row = pos.first + sx
      col = pos.last + sy
      next unless valid_location?([row, col])

      coord = board.grid[row][col]
      possible_moves << [row, col] if enemy?(coord)
    end
  end
end

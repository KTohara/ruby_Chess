# frozen_string_literal: true
require 'byebug'

# Move logic for king/knight
module StepPiece
  def moves
    move_set.each_with_object([]) do |(set_x, set_y), possible_moves|
      cur_x, cur_y = pos
      new_pos = [cur_x + set_x, cur_y + set_y]

      next unless board.valid_pos?(new_pos)
      if board[new_pos].color != color || board.empty?(new_pos)
        possible_moves << new_pos
      end
    end
  end
end

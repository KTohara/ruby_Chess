# frozen_string_literal: true

require_relative 'piece'
# require_relative 'step_piece'
require 'byebug'
# King logic
class King < Piece
  def symbol
    '♚'.color(color)
  end

  def moves
    move_set.each_with_object([]) do |set_pos, possible_moves|
      cur_x, cur_y = pos
      set_x, set_y = set_pos
      new_pos = [cur_x + set_x, cur_y + set_y]

      next unless board.valid_pos?(new_pos)

      if board[new_pos].color != color || board.empty?(new_pos)
        possible_moves << new_pos
      end
    end
  end

  def move_set
    # [[-1, -1], [-1, 0], [-1, 1], [0, 1], [1, 1], [1, 0], [1, -1], [0, -1]]
    [[0, 1]]
  end
end

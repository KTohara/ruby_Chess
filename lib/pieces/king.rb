# frozen_string_literal: true

require_relative 'piece'
require_relative 'stepping'

# King logic
class King < Piece
  include Stepping

  def symbol
    '♚'.color(color)
  end

  private

  def move_set
    [[-1, -1], [-1, 0], [-1, 1], [0, 1], [1, 1], [1, 0], [1, -1], [0, -1]]
  end
end

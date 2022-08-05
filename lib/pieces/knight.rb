# frozen_string_literal: true

require_relative 'piece'
require_relative 'stepping'

# Knight logic
class Knight < Piece
  include Stepping

  def symbol
    '♞'
  end

  private

  def move_set
    [[-2, 1], [-1, 2], [1, 2], [2, 1], [2, -1], [1, -2], [-1, -2], [-2, -1]]
  end
end

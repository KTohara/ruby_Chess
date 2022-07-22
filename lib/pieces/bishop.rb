# frozen_string_literal: true

require_relative 'piece'
require_relative 'sliding'

# Bishop logic
class Bishop < Piece
  include Sliding

  def symbol
    '♝'.color(color)
  end

  private

  def move_set
    diagonal_dir
  end
end

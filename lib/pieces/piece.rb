# frozen_string_literal: true

require_relative '../color'

# Chess piece superclass
class Piece
  attr_reader :color

  def initialize(color)
    @color = color
  end

  def to_s
    " #{symbol} "
  end

  def symbol
    # subclass placeholder method for unicode chars
  end
end

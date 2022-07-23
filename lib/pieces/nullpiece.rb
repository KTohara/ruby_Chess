# frozen_string_literal: true

# require_relative 'piece'

# Empty board space
class NullPiece
  attr_reader :symbol, :color

  def initialize(symbol = '░', color = :none)
    @symbol = symbol
    @color = color
  end

  def to_s
    "░#{symbol}░"
  end

  def empty?
    true
  end
end

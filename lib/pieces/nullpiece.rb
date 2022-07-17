# frozen_string_literal: true

require_relative 'piece'
require 'singleton'

class NullPiece < Piece
  attr_reader :symbol
  include Singleton

  def initialize
    @symbol = ' '
    @color = :none
  end

  def empty?
    true
  end
end

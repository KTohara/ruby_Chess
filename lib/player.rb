# frozen_string_literal: true

class Player
  attr_reader :color, :display

  def initialize(color, display)
    @color = color
    @display = display
  end
end

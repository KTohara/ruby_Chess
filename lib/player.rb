# frozen_string_literal: true

class Player
  attr_reader :color, :display

  def initialize(color, display)
    @color = color
    @display = display
  end

  def prompt_move(start_pos = nil, end_pos = nil)
    until start_pos && end_pos
      system('clear')
      puts display
      if start_pos
        puts "Choose where the piece goes"
        end_pos = display.cursor.key_input
      else
        puts "Choose a piece"
        start_pos = display.cursor.key_input
      end
    end
    [start_pos, end_pos]
  end
end

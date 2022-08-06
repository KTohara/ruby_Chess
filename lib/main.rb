# frozen_string_literal: true

require_relative 'game'
require_relative 'utilities'

# Chess main script
module Chess
  extend Messages
  extend SaveLoad

  def self.run
    display_intro_msg
    input = prompt_game_type until [1, 2].include?(input)
    input == 1 ? Game.new.play : load_game.play
  end
end

Chess.run if $PROGRAM_NAME == __FILE__

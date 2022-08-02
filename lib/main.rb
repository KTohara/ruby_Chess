require_relative 'game'
require_relative 'utilities'

extend Messages
extend SaveLoad

def run
  display_intro_msg
  input = prompt_game_type until [1, 2].include?(input)
  if input == 1
    game = Game.new.play
  else
    load_game.play
  end
  game.replay_game
end

run if $PROGRAM_NAME == __FILE__
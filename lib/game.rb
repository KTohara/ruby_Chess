# frozen_string_literal: true

require_relative 'board'
require_relative 'player'
require_relative 'display'

# game flow
class Game
  attr_reader :board, :player, :current_player, :display

  def initialize
    @board = Board.new
    @display = Display.new(@board)
    @players = {
      white: Player.new(:white, @display),
      black: Player.new(:black, @display)
    }
    @current_player = @players[:white]
  end

  def play
    until board.checkmate?(current_player)
      begin
        row, col = current_player.prompt_move
        board.move_piece!(row, col)
        switch_player
        display_notifications
      # rescue StandardError => e
        # debugger
        # @display.notifications[:error] = e.message
        # retry
      end
    end

    # display.render
    # puts 'checkmate'
    # nil
  end

  def switch_player; end
  def display_notifications;end
end

if $PROGRAM_NAME == __FILE__
  g = Game.new.play
end

# TO DO:
# king castling
# Board.check
# Board.checkmate
# finish Board.valid_moves
# notifications/error display
# input loops
# cursor

# TEST:
# Board.move_piece!
# Board.valid_move?

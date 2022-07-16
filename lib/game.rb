require_relative 'board'
require_relative 'player'

# game flow
class Game
  attr_reader :board, :player, :current_player, :display

  def initalize
    @board = Board.new
    @display = Display.new(@board)
    @players = {
      white: = Player.new(:white, @display),
      black: = Player.new(:black, @display)
    }
    @current_player = :white
  end

  def play
    until board.checkmate?(current_player)
      begin
        board.make_move
        board.move_piece
        switch_player
        display_notifications
      rescue StandardError => e
        @display.notifications[:error] = e.message
        retry
      end
    end
  end

  display.render
  puts 'checkmate'
  nil
end
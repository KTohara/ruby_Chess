# frozen_string_literal: true

require_relative 'board'
require_relative 'player'
require_relative 'display'
require 'byebug'

# Game flow
class Game
  attr_reader :board, :players, :current_player, :display

  def initialize
    @board = Board.new
    @display = Display.new
    @players = {
      white: Player.new(:white),
      black: Player.new(:black)
    }
    @current_player = :white
  end

  def play
    until board.checkmate?(current_player)
      begin
        player_turn
        switch_player
        board_in_check
      rescue StandardError => e
        display.notifications[:error] = e.message
        display.cursor.selected = false
        retry
      end
    end
    display.reset_notifications
    display.render(board.grid)
    puts 'Checkmate!'
  end

  private

  def player_turn
    start_pos = prompt_start_pos(current_player)
    board.validate_start_pos(current_player, start_pos)
    end_pos = prompt_end_pos(current_player, start_pos)
    board.validate_end_pos(start_pos, end_pos, current_player)
    board.move_piece(start_pos, end_pos)
  end

  def switch_player
    @current_player = current_player == :white ? :black : :white
  end

  def prompt_start_pos(turn_color, start_pos = nil)
    until start_pos
      display.render(board.grid)
      puts "#{turn_color.to_s.capitalize}, choose a piece to move"
      start_pos = display.cursor.key_input
    end
    display.reset_notifications
    start_pos
  end

  def prompt_end_pos(turn_color, start_pos, end_pos = nil)
    until end_pos
      piece = board[start_pos]
      piece.update_moves(board.grid, board.last_move) # needed for mapping moves
      display.render(board.grid, piece)
      puts "#{turn_color.to_s.capitalize}, move the piece to a position"
      p piece.moves # use to debug
      p board[start_pos] # use to debug
      end_pos = display.cursor.key_input
    end
    display.reset_notifications
    end_pos
  end

  def board_in_check
    board.check?(current_player) ? display.check_notification : display.reset_notifications
  end
end

Game.new.play if $PROGRAM_NAME == __FILE__

# TO DO:
# pawn promotion
# notifications/error display
# input loops
# cursor - handle saves

# TEST:
# king castling - check
# board.check
# board.checkmate
# board.move_piece - disallow castling

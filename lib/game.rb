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
    @current_player = players[:white]
  end

  def play
    until board.checkmate?(current_player)
      begin
        start_pos = prompt_start_pos(current_player)
        board.validate_start_pos(current_player.color, start_pos)
        end_pos = prompt_end_pos(current_player, start_pos)
        board.validate_end_pos(start_pos, end_pos)
        board.move_piece(start_pos, end_pos)
        switch_player
      rescue StandardError => e
        display.notifications[:error] = e.message
        display.cursor.selected = false
        retry
      end
    end

    # display.render
    # puts 'checkmate'
  end

  private

  def switch_player
    @current_player = current_player == players[:white] ? players[:black] : players[:white]
  end

  def prompt_start_pos(player, start_pos = nil)
    until start_pos
      display.render(board.grid)
      puts "#{player.color.to_s.capitalize}, choose a piece to move"
      start_pos = display.cursor.key_input
    end
    display.reset_notifications

    start_pos
  end

  def prompt_end_pos(player, start_pos, end_pos = nil)
    until end_pos
      piece = board[start_pos]
      piece.valid_moves(board.grid, board.last_move)
      display.render(board.grid, piece) # needs with valid_moves
      puts "#{player.color.to_s.capitalize}, move the piece to a position"
      end_pos = display.cursor.key_input
    end
    display.reset_notifications

    end_pos
  end
end

Game.new.play if $PROGRAM_NAME == __FILE__

# TO DO:
# king castling
# pawn promotion
# Board.check
# Board.checkmate
# finish Board.valid_moves
# notifications/error display
# input loops
# cursor - handle saves

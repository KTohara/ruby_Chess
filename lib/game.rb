# frozen_string_literal: true

require_relative 'board'
require_relative 'player'
require_relative 'display'
require_relative 'cursor'
require_relative 'messages'
require 'byebug'

# Game loop
class Game
  include Messages
  include Display

  attr_reader :board, :cursor, :turn_color, :display, :notifications, :messages

  def initialize
    @board = Board.new
    @cursor = Cursor.new([7, 0])
    @players = {
      white: Player.new(:white),
      black: Player.new(:black)
    }
    @turn_color = :white
    @notifications = {}
    @messages = {}
  end

  def play
    until board.checkmate?(turn_color)
      begin
        player_turn
        switch_player
        board_in_check
      rescue StandardError => e
        notifications[:error] = e.message
        cursor.selected = false
        retry
      end
    end
    game_result
  end

  private

  def player_turn
    start_pos, end_pos = handle_move_validation
    handle_special_moves(start_pos, end_pos)
    board.move_piece(start_pos, end_pos)
  end

  def handle_move_validation
    start_pos = prompt_start_pos(turn_color)
    board.validate_start_pos(turn_color, start_pos)
    end_pos = prompt_end_pos(turn_color, start_pos)
    board.validate_end_pos(start_pos, end_pos, turn_color)
    [start_pos, end_pos]
  end

  def handle_special_moves(start_pos, end_pos)
    special_move = board.special_move_type(start_pos, end_pos)
    input = special_move_msg(special_move, start_pos)
    board.execute_special_move(special_move, start_pos, end_pos, input)
  end

  def switch_player
    @turn_color = turn_color == :white ? :black : :white
  end

  def board_in_check
    board.check?(turn_color) ? add_check_notification : reset_notifications
  end

  def game_result
    reset_notifications
    render(board.grid)
    puts 'Checkmate!'
  end
end

Game.new.play if $PROGRAM_NAME == __FILE__

# TO DO:
# cursor - handle saves
# cursor - handle draw/resign
# game/board - stalemate

# TEST:
# game - #play, 
# piece - #update, #valid_location, #enemy, #list_all_moves, #list_all_captures
# cursor - #key_input

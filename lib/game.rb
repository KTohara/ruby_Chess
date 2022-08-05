# frozen_string_literal: true

require_relative 'board'
require_relative 'player'
require_relative 'utilities'

# Game loop
class Game
  include Messages
  include Display
  include SaveLoad

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

  # main game loop
  def play
    play_turn until game_over?
    game_result
  end

  # player move turn
  def play_turn
    player_move
    switch_player
    board_check_notifications
  rescue StandardError => e
    notifications[:error] = e.message
    cursor.selected = false
    retry
  end

  # prompts and validates inputs, handles any special moves, moves the piece
  def player_move
    start_pos, end_pos = player_input
    special_moves(start_pos, end_pos)
    board.move_piece(start_pos, end_pos)
  end

  # *prompts in module Messages
  # prompts for start and end position, validates both, returns position
  def player_input
    start_pos = prompt_start_pos
    check_special_inputs(start_pos)
    board.validate_start_pos(turn_color, start_pos)
    end_pos = prompt_end_pos(start_pos)
    check_special_inputs(end_pos)
    board.validate_end_pos(start_pos, end_pos, turn_color)
    [start_pos, end_pos]
  end

  def check_special_inputs(input)
    save_game if input == :save
    resign_game if input == :resign
  end

  # *msg in module Messages
  # determines special move type, outputs a message depending on move, executes the move
  def special_moves(start_pos, end_pos)
    special_move = board.special_move_type(start_pos, end_pos)
    input = special_move_msg(special_move, start_pos)
    board.execute_special_move(special_move, start_pos, end_pos, input)
  end

  # switches player to opposite color
  def switch_player
    @turn_color = turn_color == :white ? :black : :white
  end

  # if the board is in check, adds a 'board in check' message to @notification or resets notifications
  def board_check_notifications
    board.check?(turn_color) ? add_check_notification : reset_notifications
  end

  # returns true if checkmate, stalemate, or insufficient material
  def game_over?
    board.checkmate?(turn_color) || board.stalemate?(turn_color) || board.insufficient_material?
  end

  # resigns/quits if yes, resumes game if no
  def resign_game(input = nil)
    reset_messages
    reset_notifications
    add_msg_resign_game
    render(board.grid)
    input ||= prompt_yes_no
    input == 'y' ? display_thanks_then_exit : play_turn
  end

  # renders board with checkmate or draw notification
  def game_result
    reset_notifications
    board.checkmate?(turn_color) ? add_checkmate_notification : add_draw_notification
    render(board.grid)
  end

  # replays game if yes, exits if no
  def replay_game(input = nil)
    add_msg_replay
    input ||= prompt_yes_no
    input == 'y' ? Game.new.play : display_thanks_then_exit
  end
end
